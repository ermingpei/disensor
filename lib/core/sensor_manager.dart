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

import 'package:sensors_plus/sensors_plus.dart';
import 'package:noise_meter/noise_meter.dart';
import '../features/network_service.dart';

class SensorManager extends ChangeNotifier {
  final KalmanFilter _pressureFilter = KalmanFilter(q: 0.01, r: 0.1);
  NoiseMeter? _noiseMeter;
  final NetworkService _networkService = NetworkService();

  double _currentPressure = 0.0;
  double _currentDecibel = 0.0;
  String _currentNetworkType = "None";
  int _currentLatency = -1;
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

  /// Verifies if the referral code is valid.
  /// Currently performs local checks. Should be connected to backend `rpc/verify_code` ideally.
  Future<bool> verifyReferralCode(String code, String ownDeviceId) async {
    // 1. Basic format check
    if (code.length != 6) return false;

    // 2. Self-referral check
    String ownCode = ownDeviceId.substring(0, 6).toUpperCase();
    if (code.toUpperCase() == ownCode) {
      debugPrint("⚠️ Cannot refer yourself");
      return false;
    }

    // 3. Simulate Backend Validation (Network delay)
    await Future.delayed(const Duration(milliseconds: 1500));

    // TODO: Call Supabase: await supabase.rpc('check_referral_code', {'code': code})

    return true; // Assume valid for now if format is correct
  }

  double _totalEarnings = 0.0;
  double _miningRate = 1.0; // Base QBIT per valid data upload
  final Set<String> _visitedHexes = {}; // Tracks coverage in current session

  double get totalEarnings => _totalEarnings;
  double get miningRate => _miningRate;
  int get uniqueHexCount => _visitedHexes.length;

  double get pressure => _currentPressure;
  double get decibel => _currentDecibel;
  String get networkType => _currentNetworkType;
  int get latency => _currentLatency;
  bool get isSampling => _isSampling;

  final PrivacyGuard _privacyGuard = PrivacyGuard(salt: "sentinel-alpha-salt");
  DataSyncService? _syncService;

  void initSync(SupabaseClient client) {
    _syncService = DataSyncService(client: client, privacyGuard: _privacyGuard);
  }

  Future<bool> requestPermissions() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint("🔍 Location Service Enabled: $serviceEnabled");
      if (!serviceEnabled) {
        debugPrint("❌ Location services are disabled.");
        return false;
      }

      // 2. Request Location Permission
      LocationPermission locationStatus = await Geolocator.checkPermission();
      debugPrint("🔍 Initial Location Permission: $locationStatus");

      if (locationStatus == LocationPermission.denied) {
        debugPrint("📱 Requesting location permission...");
        locationStatus = await Geolocator.requestPermission();
        debugPrint("🔍 After Request Location Permission: $locationStatus");
      }

      if (locationStatus == LocationPermission.denied ||
          locationStatus == LocationPermission.deniedForever) {
        debugPrint("❌ Location permission denied: $locationStatus");
        return false;
      }

      // 3. Request Microphone (for Noise Meter)
      PermissionStatus micStatus = await Permission.microphone.status;
      debugPrint("🔍 Initial Microphone Permission: $micStatus");

      if (!micStatus.isGranted) {
        debugPrint("📱 Requesting microphone permission...");
        micStatus = await Permission.microphone.request();
        debugPrint("🔍 After Request Microphone Permission: $micStatus");
      }

      debugPrint(
          "✅ Final Permissions: Location($locationStatus), Mic($micStatus)");

      // Return true if location is granted (whileInUse or always)
      // Microphone is optional - we can still mine without it
      bool locationOK = (locationStatus == LocationPermission.whileInUse ||
          locationStatus == LocationPermission.always);
      bool micOK = micStatus.isGranted;

      debugPrint("🎯 Permission Check: Location=$locationOK, Mic=$micOK");

      // Only require location for now, mic is optional
      return locationOK;
    } catch (e) {
      debugPrint("❌ Permission request error: $e");
      return false;
    }
  }

  Future<void> startRealSampling({required String deviceId}) async {
    debugPrint("🚀 Starting Real Sampling for device: $deviceId");
    _isSampling = true;
    notifyListeners();

    // 1. Barometer (Pressure) using sensors_plus
    debugPrint("📊 Initializing Barometer...");
    try {
      _pressureSub = barometerEventStream().listen((BarometerEvent event) {
        if (_currentPressure == 0.0) {
          debugPrint("🌡️ First Barometer Reading: ${event.pressure} hPa");
        }
        _currentPressure = _pressureFilter.update(event.pressure);
        notifyListeners();
      }, onError: (e) {
        debugPrint("❌ Barometer stream error: $e");
        // Start mock data on error
        _startMockPressure();
      }, cancelOnError: false);

      debugPrint("✅ Barometer stream started successfully");
    } catch (e) {
      debugPrint("❌ Failed to start barometer: $e");
      _startMockPressure();
    }

    // 2. Noise Meter (Decibel)
    debugPrint("🎤 Initializing Noise Meter...");
    try {
      _noiseMeter ??= NoiseMeter();
      _noiseSub = _noiseMeter?.noise.listen((NoiseReading reading) {
        _currentDecibel = reading.meanDecibel;
        notifyListeners();
      }, onError: (e) => debugPrint("❌ Noise stream error: $e"));
      debugPrint("✅ Noise meter started");
    } catch (e) {
      debugPrint(
          "⚠️ Noise meter unavailable: $e (Will proceed without audio data)");
    }

    // 3. Location & Upload Flow
    final LocationSettings locationSettings = Platform.isIOS
        ? AppleSettings(
            accuracy: LocationAccuracy.best,
            activityType: ActivityType.other,
            distanceFilter: 0,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 2),
          );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _liveLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
      _checkUploadRule(position, deviceId);
    });

    // Heartbeat Poll
    _locationPollTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_isSampling) return;
      try {
        Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        _liveLocation = LatLng(pos.latitude, pos.longitude);

        // Poll Network Stats
        _currentNetworkType = await _networkService.getNetworkType();
        _currentLatency = await _networkService.measureLatency();

        notifyListeners();
        _checkUploadRule(pos, deviceId);
      } catch (e) {
        debugPrint("Hearthbeat poll skipped: $e");
      }
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

  // State for PoV Algorithm
  DateTime _lastMoveTime = DateTime.now();
  double _currentMultiplier = 1.0;
  bool _isHighValueEvent = false;

  double get currentMultiplier => _currentMultiplier;
  bool get isStationary =>
      DateTime.now().difference(_lastMoveTime).inMinutes >= 5;

  /// Decide whether to upload data based on movement or time
  void _checkUploadRule(Position position, String deviceId) async {
    if (_syncService == null) return;

    final lat = position.latitude;
    final lng = position.longitude;
    final now = DateTime.now();

    // --- 1. Movement & Stationary Logic ---
    final distDiff = (_lastLat != null && _lastLng != null)
        ? Geolocator.distanceBetween(_lastLat!, _lastLng!, lat, lng)
        : 0.0;

    if (distDiff > 20) {
      _lastMoveTime = now; // Reset stationary timer on significant move
    }

    // --- 2. High Value Event Detection ---
    // Noise > 80dB (Loud environment) OR Pressure sudden change (Storm/Elevator?)
    // Simplified trigger for noise only for now.
    _isHighValueEvent = _currentDecibel > 80.0;

    // --- 3. Determine Multiplier ---
    if (_isHighValueEvent) {
      _currentMultiplier = 3.0; // Critical Data Bonus
    } else if (isStationary) {
      _currentMultiplier = 0.1; // Idle Penalty
    } else {
      _currentMultiplier = 1.0; // Standard Mobile
    }

    // --- 4. Upload Decision (Smart Throttling) ---
    bool shouldUpload = false;
    String reason = "";
    final timeDiff = _lastUploadTime == null
        ? 9999
        : now.difference(_lastUploadTime!).inSeconds;

    if (_lastUploadTime == null) {
      shouldUpload = true;
      reason = "First pulse";
    } else {
      final noiseDiff =
          (_lastNoise != null) ? (_currentDecibel - _lastNoise!).abs() : 0.0;

      // 规则 A: Event Trigger (Immediate)
      if (_isHighValueEvent && timeDiff > 5) {
        shouldUpload = true;
        reason =
            "🔥 High Value Event (${_currentDecibel.toStringAsFixed(1)}dB)";
      }
      // 规则 B: Movement (Map Coverage)
      else if (distDiff > 10 && timeDiff > 5) {
        shouldUpload = true;
        reason = "Moved ${distDiff.toStringAsFixed(1)}m";
      }
      // 规则 C: Heartbeat (Keep-alive)
      // Stationary: Slower heartbeat (2 mins) to save server cost?
      // Or keep 30s but low reward. Let's keep 30s for visibility.
      else if (timeDiff > 30) {
        shouldUpload = true;
        reason = isStationary ? "Heartbeat (Idle)" : "Heartbeat (Mobile)";
      }
    }

    if (!shouldUpload) return;

    try {
      debugPrint("🚀 Uploading: $reason | Multiplier: x$_currentMultiplier");
      await _syncService!.uploadReading(
        deviceId: deviceId,
        pressure: _currentPressure,
        decibel: _currentDecibel,
        lat: lat,
        lng: lng,
        referredBy: _inviterId,
        networkType: _currentNetworkType,
        latency: _currentLatency,
      );

      // --- Reward Logic ---
      double earnings = _miningRate * _currentMultiplier;

      // Hex Discovery Bonus (Simulated)
      // Simple "Spatial Key" to simulate H3: 0.005 deg ~= 500m
      String spatialKey = "${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}";
      if (!_visitedHexes.contains(spatialKey)) {
        _visitedHexes.add(spatialKey);
        earnings += 2.0; // Discovery Bonus
        debugPrint("✨ New Area Discovered! +2.0 Bonus");
      }

      _totalEarnings += earnings;

      _lastUploadTime = now;
      _lastLat = lat;
      _lastLng = lng;
      _lastNoise = _currentDecibel;

      notifyListeners();
    } catch (e) {
      debugPrint("Upload process failed: $e");
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

  void _startMockPressure() {
    debugPrint("🔄 Starting mock pressure data");
    _pressureSub = Stream.periodic(
            const Duration(seconds: 5), (i) => 1013.25 + (i % 3) * 0.05)
        .listen((val) {
      _currentPressure = _pressureFilter.update(val);
      notifyListeners();
    });
  }
}
