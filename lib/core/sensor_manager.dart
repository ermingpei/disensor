import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart'; // For LatLng
import 'kalman_filter.dart';
import 'privacy_guard.dart';
import 'data_sync_service.dart';

// import 'package:h3_flutter/h3_flutter.dart';

class SensorManager extends ChangeNotifier {
  final KalmanFilter _pressureFilter = KalmanFilter(q: 0.01, r: 0.1);
  // final H3 _h3 = const H3(); // Initialize H3

  double _currentPressure = 0.0;
  double _currentDecibel = 0.0;
  bool _isSampling = false;

  StreamSubscription? _pressureSub;
  StreamSubscription? _noiseSub;
  StreamSubscription? _positionSub;
  Timer? _locationPollTimer;

  String? _inviterId;
  String? get inviterId => _inviterId;
  set inviterId(String? val) {
    _inviterId = val;
    notifyListeners();
  }

  double get pressure => _currentPressure;
  double get decibel => _currentDecibel;
  bool get isSampling => _isSampling;

  final PrivacyGuard _privacyGuard = PrivacyGuard(salt: "sentinel-alpha-salt");
  DataSyncService? _syncService;

  void initSync(SupabaseClient client) {
    _syncService = DataSyncService(client: client, privacyGuard: _privacyGuard);
  }

  Future<bool> requestPermissions() async {
    try {
      // iOS 需要明确请求 Always 权限以支持后台运行
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 如果不是 "Always"，我们需要引导用户去设置里开启（对于后台采集至关重要）
      // 这里简化流程，只记录状态
      debugPrint("Current Location Permission: $permission");

      return true;
    } catch (e) {
      debugPrint("Permission request error: $e");
      return false;
    }
  }

  Future<void> startRealSampling({required String deviceId}) async {
    _isSampling = true;
    notifyListeners();

    // 配置后台定位参数 - Optimized for indoor
    final LocationSettings locationSettings = Platform.isIOS
        ? AppleSettings(
            accuracy: LocationAccuracy.best, // Best available (WiFi/Cell/GPS)
            activityType: ActivityType.fitness,
            distanceFilter: 0, // Fire on ANY movement
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true, // 状态栏蓝条，保活的关键
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0, // Fire on ANY movement
            forceLocationManager: false, // Use Fused (better for indoor)
            intervalDuration: const Duration(seconds: 2),
          );

    // 1. Position Stream (Map Updates)
    // This drives the "Pin" movement on the map seamlessly
    try {
      _positionSub =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        debugPrint(
            "📍 Location Stream Update: ${position.latitude}, ${position.longitude} (±${position.accuracy.toStringAsFixed(1)}m)");

        // Update UI
        _liveLocation = LatLng(position.latitude, position.longitude);
        notifyListeners();

        // Check if we should upload this point
        _checkUploadRule(position, deviceId);
      }, onError: (e) {
        debugPrint("⚠️ Location stream error: $e");
      });
    } catch (e) {
      debugPrint("Failed to start location stream: $e");
    }

    // 1.5. Fallback: Poll location every 3 seconds (for weak GPS/indoor)
    _locationPollTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (!_isSampling) {
        timer.cancel();
        return;
      }

      try {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 2),
        );

        // Update UI even if no significant movement (helps verify it's working)
        double distFromLast = _liveLocation != null
            ? Geolocator.distanceBetween(_liveLocation!.latitude,
                _liveLocation!.longitude, pos.latitude, pos.longitude)
            : 999;

        if (_liveLocation == null || distFromLast > 0.5) {
          debugPrint(
              "🔄 Poll Update: ${pos.latitude}, ${pos.longitude} (moved ${distFromLast.toStringAsFixed(1)}m)");
          _liveLocation = LatLng(pos.latitude, pos.longitude);
          notifyListeners();
        }
      } catch (e) {
        debugPrint("ℹ️ Poll skipped: $e");
      }
    });

    // 2. Sensors (Mock for now, but independent of upload trigger)
    _pressureSub = Stream.periodic(
            const Duration(seconds: 2), (i) => 1013.25 + (i % 5) * 0.1)
        .listen((val) {
      _currentPressure = _pressureFilter.update(val);
      notifyListeners();
    });

    _noiseSub = Stream.periodic(
            const Duration(seconds: 2), (i) => 35.0 + (i % 10).toDouble())
        .listen((val) {
      _currentDecibel = val;
      notifyListeners();
    });
  }

  void startMockSampling({
    required Stream<double> pressureSource,
    required Stream<double> noiseSource,
    String? deviceId,
  }) {
    _isSampling = true;
    notifyListeners();

    _pressureSub = pressureSource.listen((val) {
      _currentPressure = _pressureFilter.update(val);
      notifyListeners();
      // For mock, we can just randomly simulate upload if needed,
      // or rely on a wrapper to inject location.
      // Simplified: Mock doesn't auto-upload location in this basic version.
    });

    _noiseSub = noiseSource.listen((val) {
      _currentDecibel = val;
      notifyListeners();
    });
  }

  // 智能过滤状态
  DateTime? _lastUploadTime;
  double? _lastLat;
  double? _lastLng;
  double? _lastNoise;

  LatLng? _liveLocation;
  LatLng? get liveLocation => _liveLocation;

  /// Decide whether to upload data based on movement or time
  void _checkUploadRule(Position position, String deviceId) async {
    if (_syncService == null) return;

    final lat = position.latitude;
    final lng = position.longitude;

    // 2. 智能节流逻辑 (Smart Throttling)
    final now = DateTime.now();
    bool shouldUpload = false;
    String reason = "";

    if (_lastUploadTime == null) {
      shouldUpload = true; // 第一条数据必发
      reason = "First pulse";
    } else {
      final timeDiff = now.difference(_lastUploadTime!).inSeconds;
      final distDiff = (_lastLat != null && _lastLng != null)
          ? Geolocator.distanceBetween(_lastLat!, _lastLng!, lat, lng)
          : 0.0;
      final noiseDiff =
          (_lastNoise != null) ? (_currentDecibel - _lastNoise!).abs() : 0.0;

      // 规则 A: 最小间隔 2秒 (To avoid flooding)
      if (timeDiff < 2) {
        // Too fast, ignore unless urgent?
        // For now just basic throttling.
      } else {
        // 规则 B: 移动距离 > 5米 (More granular for map)
        if (distDiff > 5) {
          shouldUpload = true;
          reason = "Moved ${distDiff.toStringAsFixed(1)}m";
        }
        // 规则 C: 强制心跳 (每 30s 发一次)
        else if (timeDiff > 30) {
          shouldUpload = true;
          reason = "Heartbeat";
        }
        // 规则 D: 显著噪音变化 (Event)
        else if (noiseDiff > 5.0) {
          shouldUpload = true;
          reason = "Noise Event";
        }
      }
    }

    if (!shouldUpload) {
      return;
    }

    try {
      debugPrint("🚀 Uploading: $reason");
      await _syncService!.uploadReading(
        deviceId: deviceId,
        pressure: _currentPressure,
        decibel: _currentDecibel,
        lat: lat,
        lng: lng,
        referredBy: _inviterId,
      );

      // 更新状态
      _lastUploadTime = now;
      _lastLat = lat;
      _lastLng = lng;
      _lastNoise = _currentDecibel;
    } catch (e) {
      debugPrint("Data sync pulse skipped: $e");
    }
  }

  void stopSampling() {
    _isSampling = false;
    _pressureSub?.cancel();
    _noiseSub?.cancel();
    _positionSub?.cancel();
    _locationPollTimer?.cancel();
    notifyListeners();
  }
}
