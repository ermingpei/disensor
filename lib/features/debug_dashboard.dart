import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/sensor_manager.dart';
import '../core/app_strings.dart';
import 'hex_map_page.dart';
import 'onboarding_page.dart';
import 'widgets/qbit_icon.dart';

class DebugDashboard extends StatefulWidget {
  @override
  _DebugDashboardState createState() => _DebugDashboardState();
}

class _DebugDashboardState extends State<DebugDashboard>
    with WidgetsBindingObserver {
  String? _tempInviteCode;
  String? deviceId;
  bool _isCheckingCode = false;
  bool _showInput = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeviceId();

    // Check clipboard after first frame to ensure we are "foreground" enough for Android 10+
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkClipboard();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User just came back (e.g. from browser copy), check clipboard again
      _checkClipboard();
    }
  }

  /// Separated method to check clipboard for invite codes
  Future<void> _checkClipboard() async {
    // 1. If we already have a code applied, don't bother
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('inviter_code') != null) return;

    // 2. Read Clipboard
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim().toUpperCase();

      // 3. Check for 6-char AlphaNumeric code
      if (text != null &&
          text.length == 6 &&
          RegExp(r'^[A-Z0-9]{6}$').hasMatch(text)) {
        // Avoid re-alerting if we already detected this specific code in this session
        if (_tempInviteCode == text) return;

        debugPrint("📋 Detected potential code in clipboard: $text");
        setState(() {
          _tempInviteCode = text;
          _showInput = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("📋 Found Code: $text"),
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
                label: "APPLY NOW",
                textColor: Colors.amber,
                onPressed: () {
                  _verifyAndApplyCode(text);
                }),
          ));
        }
      }
    } catch (e) {
      debugPrint("Clipboard error: $e");
    }
  }

  Future<void> _initDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('sentinel_device_id');
    String? storedInviter = prefs.getString('inviter_code');

    if (storedId == null) {
      storedId = const Uuid().v4();
      await prefs.setString('sentinel_device_id', storedId);
    }

    if (mounted) {
      setState(() {
        deviceId = storedId;
      });
      if (storedInviter != null) {
        final manager = Provider.of<SensorManager>(context, listen: false);
        manager.inviterId = storedInviter;
      }
    }
  }

  void _shareInvite() {
    final code = deviceId?.substring(0, 6).toUpperCase() ?? 'XXXXXX';
    final String shareText = "📱【DiSensor】\n"
        "${AppStrings.t('invite_desc')}\n"
        "👉 Code: *$code*\n"
        "https://ermingpei.github.io/disensor/dashboard/start.html?ref=$code";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    // Cyber-Professional Palette
    final bgColor = Color(0xFF0B1021); // Deep Midnight

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Updated Icon - using asset image with Rounded Corners
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/icon/icon.png', width: 28, height: 28),
            ),
            SizedBox(width: 10),
            // Title Image
            Image.asset(
              'assets/icon/disensor_title.png',
              height: 40, // Increased size (approx 1.7x)
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  "DiSensor",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                            blurRadius: 10,
                            color: Colors.cyanAccent.withOpacity(0.5),
                            offset: Offset(0, 0))
                      ]),
                );
              },
            ),
          ],
        ),
        backgroundColor:
            Color(0xFF0F1424).withOpacity(0.9), // Slightly lighter header
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white70),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  backgroundColor: Color(0xFF1A1A2E),
                  title: Text(AppStrings.t('settings_title'),
                      style: TextStyle(color: Colors.white)),
                  children: [
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.cyanAccent),
                      title: Text(AppStrings.t('version'),
                          style: TextStyle(color: Colors.white70)),
                      subtitle: Text("v1.0.3",
                          style: TextStyle(color: Colors.white54)),
                    ),
                    ListTile(
                      leading: Icon(Icons.business, color: Colors.cyanAccent),
                      title: Text(AppStrings.t('powered_by'),
                          style: TextStyle(color: Colors.white70)),
                      subtitle: Text("Qubit Rhythm",
                          style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.privacy_tip, color: Colors.cyanAccent),
                      title: Text(AppStrings.t('privacy_policy'),
                          style: TextStyle(color: Colors.white70)),
                      onTap: () => Navigator.pop(ctx),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.restart_alt, color: Colors.orangeAccent),
                      title: Text(AppStrings.t('replay_tutorial'),
                          style: TextStyle(color: Colors.white70)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('seenOnboarding', false);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OnboardingPage()));
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        children: [
          Consumer<SensorManager>(
            builder: (context, manager, _) => _buildMiningMainCard(manager),
          ),
          SizedBox(height: 16),
          _buildNetworkStats(),
          SizedBox(height: 16),
          Consumer<SensorManager>(
            builder: (context, manager, _) => Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    AppStrings.t('pressure'),
                    '${manager.pressure.toStringAsFixed(2)}',
                    'hPa',
                    Icons.speed,
                    Colors.cyan,
                    AppStrings.t('pressure_desc'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    AppStrings.t('noise'),
                    '${manager.decibel.toStringAsFixed(1)}',
                    'dB',
                    Icons.graphic_eq,
                    Colors.purpleAccent,
                    AppStrings.t('noise_desc'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildExtraSensors(),
          SizedBox(height: 24),
          _buildMiniMapStatic(context),
          SizedBox(height: 24),
          _buildReferralSection(),
          SizedBox(height: 24),
          Consumer<SensorManager>(
            builder: (context, manager, _) => _buildInputSection(manager),
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildExtraSensors() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xFF151A30), // Solid Navy
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("DEVICE SENSORS",
              style: TextStyle(
                  color: Colors.cyanAccent.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StreamBuilder<AccelerometerEvent>(
                    stream: accelerometerEventStream(),
                    builder: (context, snapshot) {
                      String val = "Standby";
                      if (snapshot.hasData) {
                        val = "Active";
                      }
                      return _buildSensorChip(
                          "Accelerometer", val, Icons.vibration, Colors.orange);
                    }),
                SizedBox(width: 12),
                _buildSensorChip(
                    "Gyroscope", "Active", Icons.rotate_right, Colors.blue),
                SizedBox(width: 12),
                _buildSensorChip(
                    "Magnetometer", "Ready", Icons.explore, Colors.red),
                SizedBox(width: 12),
                _buildSensorChip(
                    "Light", "On", Icons.light_mode, Colors.yellow),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSensorChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Color(0xFF1F2640),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.white60, fontSize: 10)),
              Text(value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniMapStatic(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => HexMapPage())),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black38, blurRadius: 15, offset: Offset(0, 8)),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // The Map
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(37.7749, -122.4194),
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none, // Static behavior
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sensor_sentinel',
                    tileBuilder: (context, widget, tile) {
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.6),
                          BlendMode.darken,
                        ),
                        child: widget,
                      );
                    },
                  ),
                ],
              ),
              // Overlay Text
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map, color: Colors.cyanAccent, size: 20),
                        SizedBox(width: 8),
                        Text(AppStrings.t('coverage_map'),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppStrings.t('map_desc'),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF0B1021).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                  ),
                  child: Text("LIVE VIEW",
                      style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkStats() {
    return Consumer<SensorManager>(builder: (context, manager, _) {
      String netType = manager.networkType;
      String latency = manager.latency > 0 ? '${manager.latency}ms' : '--';
      Color netColor = netType == 'WiFi' ? Colors.blue : Colors.purpleAccent;

      return Row(
        children: [
          _buildStatBox(
              AppStrings.t('network'),
              netType,
              netType == 'WiFi' ? Icons.wifi : Icons.signal_cellular_alt,
              netColor),
          SizedBox(width: 10),
          _buildStatBox(
              AppStrings.t('latency'), latency, Icons.bolt, Colors.orange),
          SizedBox(width: 10),
          _buildStatBox(AppStrings.t('hexes'), '${manager.uniqueHexCount}',
              Icons.hexagon, Colors.green),
        ],
      );
    });
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF151A30), Color(0xFF1F2640)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
            ]),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  // Custom QBit Coin Icon
  Widget _buildQBitCoin() {
    return QBitIcon(size: 42);
  }

  Widget _buildMiningMainCard(SensorManager manager) {
    bool isSampling = manager.isSampling;
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSampling
                ? [Color(0xFF1A2B2F), Color(0xFF0F1424)] // Slight greenish tint
                : [Color(0xFF151A30), Color(0xFF1F2640)]),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: isSampling
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.white10),
        boxShadow: [
          BoxShadow(
              color: Colors.black38, blurRadius: 15, offset: Offset(0, 8)),
          if (isSampling)
            BoxShadow(
                color: Colors.greenAccent.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: -5),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t('estimated_earnings'),
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            letterSpacing: 1.5)),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // New Icon
                        _buildQBitCoin(),
                        SizedBox(width: 12),
                        // Number
                        Flexible(
                          child: Text(
                            manager.totalEarnings.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildMultiplierBadge(manager),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white24),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(AppStrings.t('about_qbit')),
                      content: Text(AppStrings.t('about_qbit_content')),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(AppStrings.t('got_it')))
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          SizedBox(height: 24),
          Divider(color: Colors.white10, height: 1),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.flash_on, color: Colors.orangeAccent, size: 16),
                  SizedBox(width: 4),
                  Text('${manager.miningRate.toStringAsFixed(1)} QBIT/hr',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (manager.isSampling) {
                    manager.stopSampling();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.sync, color: Colors.white, size: 16),
                          SizedBox(width: 12),
                          Text(AppStrings.t('checking_permissions')),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.blue.shade700,
                    ));

                    bool granted = await manager.requestPermissions();

                    if (granted) {
                      await manager.startRealSampling(
                          deviceId: deviceId ?? "DEVICE-1");

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppStrings.t('mining_started')),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ));
                    } else {
                      bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      LocationPermission perm =
                          await Geolocator.checkPermission();

                      String message = AppStrings.t('location_required');
                      bool showSettings = false;

                      if (!serviceEnabled) {
                        message = AppStrings.t('turn_on_gps');
                      } else if (perm == LocationPermission.deniedForever) {
                        message = AppStrings.t('perm_denied_forever');
                        showSettings = true;
                      } else if (perm == LocationPermission.denied) {
                        message = AppStrings.t('allow_location');
                      }

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message),
                        backgroundColor:
                            showSettings ? Colors.orange : Colors.redAccent,
                        duration: Duration(seconds: 5),
                        action: showSettings
                            ? SnackBarAction(
                                label: AppStrings.t('settings'),
                                onPressed: () => Geolocator.openAppSettings(),
                                textColor: Colors.white)
                            : null,
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSampling ? Color(0xFF2D2D2D) : Colors.greenAccent,
                  foregroundColor: isSampling ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                    isSampling
                        ? AppStrings.t('pause_mining')
                        : AppStrings.t('resume_mining'),
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierBadge(SensorManager manager) {
    double mult = manager.currentMultiplier;
    Color color;
    String text;
    IconData icon;

    if (mult >= 3.0) {
      color = Colors.purpleAccent;
      text = "EVENT BONUS";
      icon = Icons.bolt;
    } else if (mult >= 1.0) {
      color = Colors.greenAccent;
      text = "ACTIVE";
      icon = Icons.directions_walk;
    } else {
      color = Colors.orangeAccent;
      text = "IDLE";
      icon = Icons.snooze;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            "x${mult.toStringAsFixed(1)} $text",
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit,
      IconData icon, Color color, String desc) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(children: [
              Icon(icon, color: color),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white))
            ]),
            content: Text(desc, style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("OK", style: TextStyle(color: Colors.cyanAccent)))
            ],
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(value,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyAndApplyCode(String code) async {
    if (code.length != 6) return;

    setState(() => _isCheckingCode = true);

    // Simple delay simulation or real check
    await Future.delayed(Duration(seconds: 1));
    if (!mounted) return;

    final manager = Provider.of<SensorManager>(context, listen: false);

    // Self-referral check (Basic)
    if (deviceId != null && deviceId!.startsWith(code)) {
      setState(() => _isCheckingCode = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("⚠️ Cannot refer yourself.")));
      return;
    }

    final success =
        await manager.verifyReferralCode(code, deviceId ?? "UNKNOWN");

    if (success) {
      manager.inviterId = code;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('inviter_code', code);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppStrings.t('invite_activated') ??
              "Invite Activated! Boost applied. 🚀"),
          backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ Invalid code"), backgroundColor: Colors.redAccent));
    }

    if (mounted) {
      setState(() {
        _isCheckingCode = false;
        // Optionally keep input shown or hide it
      });
    }
  }

  Widget _buildReferralSection() {
    final code = deviceId?.substring(0, 6).toUpperCase() ?? '...';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _shareInvite,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.t('invite_earn'),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 6),
                          Text(AppStrings.t('invite_desc'),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('CODE',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  letterSpacing: 1.5)),
                          SizedBox(height: 2),
                          Text(code,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.t('share_link'),
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(SensorManager manager) {
    bool isActivated = (manager.inviterId ?? '').isNotEmpty;

    if (isActivated) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
            boxShadow: [
              BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2)
            ]),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(AppStrings.t('boost_active'),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "${AppStrings.t('referred_by')} ${manager.inviterId}",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(AppStrings.t('mining_efficiency'),
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            )
          ],
        ),
      );
    }

    if (!_showInput) {
      return Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              _showInput = true;
            });
          },
          child: Text(
            AppStrings.t('have_invite'),
            style: TextStyle(
                color: Colors.white54, decoration: TextDecoration.underline),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: AppStrings.t('enter_code'),
                labelStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                hintText: 'ABC123',
                hintStyle: TextStyle(color: Colors.white24),
              ),
              maxLength: 6,
              buildCounter: null,
              textCapitalization: TextCapitalization.characters,
              onChanged: (val) => _tempInviteCode = val.toUpperCase(),
              enabled: !_isCheckingCode,
            ),
          ),
          SizedBox(width: 8),
          _isCheckingCode
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.greenAccent),
                  onPressed: () async {
                    if (_tempInviteCode == null || _tempInviteCode!.length != 6)
                      return;
                    setState(() => _isCheckingCode = true);

                    // Simple delay simulation or real check
                    await Future.delayed(Duration(seconds: 1));
                    final manager =
                        Provider.of<SensorManager>(context, listen: false);
                    manager.inviterId = _tempInviteCode;

                    // Save
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('inviter_code', _tempInviteCode!);

                    setState(() {
                      _isCheckingCode = false;
                    });
                  },
                )
        ],
      ),
    );
  }
}
