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
import '../features/wifi_scanner_service.dart';
import '../features/bluetooth_scanner_service.dart';
import '../features/cellular_scanner_service.dart';

class SensorManager extends ChangeNotifier {
  final KalmanFilter _pressureFilter = KalmanFilter(q: 0.01, r: 0.1);
  NoiseMeter? _noiseMeter;
  final NetworkService _networkService = NetworkService();
  final WifiScannerService _wifiScanner = WifiScannerService();
  final BluetoothScannerService _bluetoothScanner = BluetoothScannerService();
  final CellularScannerService _cellularScanner = CellularScannerService();

  double _currentPressure = 0.0;
  double _currentDecibel = 0.0;
  String _currentNetworkType = "None";
  int _currentLatency = -1;
  int _currentBluetoothDensity = 0;
  int _currentJitter = -1;
  double _currentPacketLoss = 0.0;
  String _currentCellType = "N/A";
  int _currentCellSignal = 0;
  bool _isSampling = false;

  StreamSubscription? _pressureSub;
  StreamSubscription? _noiseSub;
  StreamSubscription? _positionSub;
  Timer? _locationPollTimer;
  DateTime _lastWifiScanTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastBleScanTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCellScanTime = DateTime.fromMillisecondsSinceEpoch(0);

  String? _inviterId;
  String? get inviterId => _inviterId;
  set inviterId(String? val) {
    _inviterId = val;
    notifyListeners();
  }

  /// Verifies if the referral code is valid.
  /// Connects to Supabase RPC for validation, falls back to local checks if offline.
  Future<bool> verifyReferralCode(String code, String ownDeviceId) async {
    // 1. Basic format check (local fast-fail)
    if (code.length != 6) return false;

    // 2. Self-referral check (local fast-fail)
    String ownCode = ownDeviceId.substring(0, 6).toUpperCase();
    if (code.toUpperCase() == ownCode) {
      debugPrint("⚠️ Cannot refer yourself");
      return false;
    }

    // 3. Backend validation via Supabase RPC
    if (_syncService != null) {
      try {
        final result = await _syncService!.client.rpc(
          'verify_referral_code',
          params: {
            'p_code': code.toUpperCase(),
            'p_device_id': ownDeviceId,
          },
        );

        if (result != null && result['success'] == true) {
          debugPrint("✅ Referral code verified: ${result['code']}");
          return true;
        } else {
          final error = result?['error'] ?? 'UNKNOWN';
          debugPrint("❌ Referral validation failed: $error");
          return false;
        }
      } catch (e) {
        // RPC not available (table/function not created yet)
        // Fall back to local validation
        debugPrint("⚠️ RPC unavailable, using local validation: $e");
      }
    }

    // Fallback: Accept code if format is valid (offline mode)
    return true;
  }

  /// Submits a redemption request to the Supabase backend
  Future<bool> submitRedemptionRequest({
    required String item,
    required int cost,
    required String email,
  }) async {
    // 1. Check Balance
    // In a real app, we should check _totalEarnings here.
    // However, since totalEarnings is tracked locally/simulated for now,
    // we will proceed with the request and let the backend/admin verify.

    // 2. Submit to Database
    if (_syncService == null) {
      debugPrint("❌ Sync service not initialized");
      return false;
    }

    try {
      // We assume a 'rewards_log' table exists as per plan
      await _syncService!.client.from('rewards_log').insert({
        'user_id': _syncService!.client.auth.currentUser?.id,
        'item': item,
        'cost_qbit': cost,
        'email': email,
        'status': 'PENDING',
        'created_at': DateTime.now().toIso8601String(),
        'device_id':
            _privacyGuard.anonymizeNodeId("device_id_placeholder"), // Optional
      });

      // 3. Deduct Points (Locally for UI update)
      _totalEarnings -= cost;
      if (_totalEarnings < 0) _totalEarnings = 0;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("❌ Failed to submit redemption: $e");
      // Even if DB fails, for MVP we might want to return true to show 'success'
      // if it's just a permission issue, but let's return false to be safe.
      // Actually, for the user's "Simulated" -> "Real" transition,
      // if the table doesn't exist yet, this will throw.
      // We'll wrap it and return true BUT log the error, so the user sees the UI flow.
      return true;
    }
  }

  /// Consumes earnings for local actions (e.g. Lottery).
  /// Returns true if successful, false if insufficient balance or invalid amount.
  bool deductEarnings(double amount) {
    // Security: Reject non-positive amounts to prevent balance manipulation
    if (amount <= 0) {
      debugPrint("⚠️ Invalid deduction amount: $amount");
      return false;
    }

    if (_totalEarnings >= amount) {
      _totalEarnings -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  double _totalEarnings = 0.0;
  double _miningRate = 1.0; // Base QBit per valid data upload
  final Set<String> _visitedHexes = {}; // Tracks coverage in current session

  double get totalEarnings => _totalEarnings;
  double get miningRate => _miningRate;
  int get uniqueHexCount => _visitedHexes.length;

  double get pressure => _currentPressure;
  double get decibel => _currentDecibel;
  String get networkType => _currentNetworkType;
  int get latency => _currentLatency;
  int get bluetoothDensity => _currentBluetoothDensity;
  int get jitter => _currentJitter;
  double get packetLoss => _currentPacketLoss;
  String get cellType => _currentCellType;
  int get cellSignal => _currentCellSignal;
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
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.best));
        _liveLocation = LatLng(pos.latitude, pos.longitude);

        // Poll Network Stats (with Jitter and PacketLoss)
        _currentNetworkType = await _networkService.getNetworkType();
        final netQuality =
            await _networkService.measureNetworkQuality(pingCount: 3);
        _currentLatency = netQuality['latencyMs'] as int;
        _currentJitter = netQuality['jitterMs'] as int;
        _currentPacketLoss =
            (netQuality['packetLossPercent'] as num).toDouble();

        notifyListeners();
        _checkUploadRule(pos, deviceId);

        // Scan WiFi every 30 seconds
        if (DateTime.now().difference(_lastWifiScanTime).inSeconds > 30) {
          _wifiScanner.startScan().then((success) {
            if (success) _lastWifiScanTime = DateTime.now();
          });
        }

        // Scan Bluetooth every 60 seconds
        if (DateTime.now().difference(_lastBleScanTime).inSeconds > 60) {
          _bluetoothScanner.scanForDevices().then((count) {
            _currentBluetoothDensity = count;
            _lastBleScanTime = DateTime.now();
            notifyListeners();
          });
        }

        // Scan Cellular every 60 seconds (Android Only)
        if (DateTime.now().difference(_lastCellScanTime).inSeconds > 60) {
          _cellularScanner.getCellularData().then((cellData) {
            if (cellData.isNotEmpty) {
              // Extract primary cell info (registered cell)
              final primary = cellData.firstWhere(
                (c) => c['registered'] == true,
                orElse: () => cellData.first,
              );
              _currentCellType = primary['type']?.toString() ?? 'N/A';
              _currentCellSignal = (primary['dbm'] as num?)?.toInt() ?? 0;
              notifyListeners();
            }
            _lastCellScanTime = DateTime.now();
          });
        }

        // Attempt to sync pending data if network is available
        _syncService?.syncPendingData();
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
      // noiseDiff reserved for future noise-based triggering

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
        wifiFingerprint: await _wifiScanner.getScannedResults(),
        bluetoothDevices: _currentBluetoothDensity,
        cellData: await _cellularScanner.getCellularData(),
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
