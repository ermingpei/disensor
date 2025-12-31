import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; // Needed for Mini Map

import '../core/sensor_manager.dart';
import 'hex_map_page.dart'; // Import the new file

class DebugDashboard extends StatefulWidget {
  @override
  _DebugDashboardState createState() => _DebugDashboardState();
}

class _DebugDashboardState extends State<DebugDashboard> {
  String? _tempInviteCode;
  String? deviceId;
  LatLng? _previewLocation; // For MiniMap

  @override
  void initState() {
    super.initState();
    _initDeviceId();
    _initLocationPreview();
  }

  Future<void> _initLocationPreview() async {
    try {
      // Just a rough check, don't block
      Position pos =
          await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _previewLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {
      // If fails (e.g. no permission), just ignore. Map will show loading or default.
    }
  }

  Future<void> _initDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('sentinel_device_id');

    if (storedId == null) {
      storedId = const Uuid().v4();
      await prefs.setString('sentinel_device_id', storedId);
    }

    setState(() {
      deviceId = storedId;
    });
  }

  void _shareInvite() {
    final code = deviceId?.substring(0, 6).toUpperCase() ?? 'XXXXXX';
    final String shareText = "📱【DiSensor: 利用手机空闲时间获益!】\n"
        "您是否注意到您的手机大部分时间都在空闲？而您其实可以用这些空闲贡献数据为自己赚钱？\n"
        "DiSensor 帮您利用手机闲置的气压/噪声等传感器，为全球环境监测网络贡献数据，同时躺赚被动收益！\n"
        "📈 越早加入收益越多。赶紧加入吧！\n"
        "👉 20% 永久算力加成邀请码: *$code*\n"
        "下载链接: https://disensor.app/start?ref=$code\n\n"
        "--------------------\n\n"
        "📱 [DiSensor: Monetize Your Phone's Idle Time!]\n"
        "Did you notice your phone sits idle most of the time? You could be turning that downtime into earnings!\n"
        "DiSensor utilizes your device's idle sensors (Barometer/Noise) to contribute to a global environmental network, generating passive income for you effortlessly.\n"
        "📈 Early adopters earn more. Join now!\n"
        "👉 Use code *$code* for a 20% permanent bonus boost.\n"
        "Download: https://disensor.app/start?ref=$code";

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark premium background
      appBar: AppBar(
        title: Text('DiSensor', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white70),
            onPressed: () {},
          )
        ],
      ),
      body: Consumer<SensorManager>(
        builder: (context, manager, child) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Status & Controls
                  _buildStatusCard(manager),

                  SizedBox(height: 24),

                  // 2. Data Metrics
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricCard(
                              'Pressure',
                              '${manager.pressure.toStringAsFixed(2)}',
                              'hPa',
                              Icons.speed,
                              Colors.cyan)),
                      SizedBox(width: 12),
                      Expanded(
                          child: _buildMetricCard(
                              'Noise Level',
                              '${manager.decibel.toStringAsFixed(1)}',
                              'dB',
                              Icons.mic,
                              Colors.pinkAccent)),
                    ],
                  ),

                  SizedBox(height: 24),

                  // 3. Mini Map Preview (Interactive Entry)
                  _buildMiniMapCard(context),

                  SizedBox(height: 24),

                  // 4. Premium Referral Section
                  _buildReferralSection(),

                  SizedBox(height: 24),

                  // 5. Invite Code Input
                  _buildInputSection(manager),

                  SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMiniMapCard(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Map (Static-ish)
          if (_previewLocation != null)
            IgnorePointer(
              ignoring: true, // Make map strictly visual so tap goes to InkWell
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _previewLocation!,
                  initialZoom: 13.0,
                  interactionOptions: InteractionOptions(
                      flags: InteractiveFlag.none), // Disable pan/zoom
                ),
                children: [
                  // Use OSM for mini map too
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sensor_sentinel',
                  ),
                  CircleLayer(circles: [
                    CircleMarker(
                        point: _previewLocation!,
                        radius: 80,
                        useRadiusInMeter: true,
                        color: Colors.green.withOpacity(0.3),
                        borderColor: Colors.green,
                        borderStrokeWidth: 2),
                  ])
                ],
              ),
            )
          else
            Container(
              color: Colors.grey[800],
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_searching,
                      color: Colors.white24, size: 40),
                  SizedBox(height: 10),
                  Text("Locating...", style: TextStyle(color: Colors.white30))
                ],
              )),
            ),

          // Overlay Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: [0.5, 1.0],
              ),
            ),
          ),

          // Text & Button Overlay
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Global Coverage",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    SizedBox(height: 2),
                    Text("Explore High Yield Areas",
                        style:
                            TextStyle(color: Colors.greenAccent, fontSize: 10)),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),

          // Tap Handler
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HexMapPage())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SensorManager manager) {
    bool isSampling = manager.isSampling;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Device Status',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSampling
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(isSampling ? 'MINING ACTIVE' : 'IDLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (manager.isSampling) {
                    manager.stopSampling();
                  } else {
                    bool granted = await manager.requestPermissions();
                    if (granted) {
                      await manager.startRealSampling(
                          deviceId: deviceId ?? "UNKNOWN-DEVICE");
                    } else {
                      manager.startMockSampling(
                        pressureSource: Stream.periodic(Duration(seconds: 1),
                            (i) => 1013.25 + (i % 5) * 0.1),
                        noiseSource: Stream.periodic(
                            Duration(seconds: 1), (i) => 35.0 + (i % 10)),
                        deviceId: deviceId ?? "UNKNOWN-MOCK",
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(isSampling ? 'STOP' : 'START'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSampling
                      ? Colors.red.withOpacity(0.8)
                      : Colors.greenAccent,
                  foregroundColor: isSampling ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String unit, IconData icon, Color color) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(width: 4),
              Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
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
                    // --- FIX: Wrapped in Expanded to prevent overflow ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invite & Earn 💰',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 6),
                          Text('Get 20% constant bonus\nfrom every friend!',
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
                      'Share Link Now',
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Have a code? Enter it here',
                labelStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                hintText: 'ABC123',
                hintStyle: TextStyle(color: Colors.white24),
              ),
              maxLength: 6,
              buildCounter: null,
              textCapitalization: TextCapitalization.characters,
              onChanged: (val) => _tempInviteCode = val.toUpperCase(),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.greenAccent, size: 32),
            onPressed: () {
              if (_tempInviteCode != null && _tempInviteCode!.length == 6) {
                manager.inviterId = _tempInviteCode;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Invite code activated! Boost applied. 🚀')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
