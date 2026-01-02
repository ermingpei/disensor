import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; // Needed for Mini Map

import '../core/sensor_manager.dart';
import 'hex_map_page.dart';
import 'onboarding_page.dart'; // Import for settings navigation

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
    String? storedInviter = prefs.getString('inviter_code');

    if (storedId == null) {
      storedId = const Uuid().v4();
      await prefs.setString('sentinel_device_id', storedId);
    }

    if (mounted) {
      setState(() {
        deviceId = storedId;
      });

      // Update manager if we have a stored inviter code
      if (storedInviter != null) {
        final manager = Provider.of<SensorManager>(context, listen: false);
        manager.inviterId = storedInviter;
      }
    }
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
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hexagon_outlined, color: Colors.cyanAccent, size: 24),
            SizedBox(width: 8),
            Text(
              "DiSENSOR",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        blurRadius: 12,
                        color: Colors.cyanAccent.withOpacity(0.6),
                        offset: Offset(0, 0))
                  ]),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.3),
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
                  title: Text("Settings & About",
                      style: TextStyle(color: Colors.white)),
                  children: [
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.cyanAccent),
                      title: Text("Version",
                          style: TextStyle(color: Colors.white70)),
                      subtitle: Text("v1.0.2 (Alpha)",
                          style: TextStyle(color: Colors.white54)),
                    ),
                    ListTile(
                      leading: Icon(Icons.business, color: Colors.cyanAccent),
                      title: Text("Powered by",
                          style: TextStyle(color: Colors.white70)),
                      subtitle: Text("Qubit Rhythm",
                          style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.privacy_tip, color: Colors.cyanAccent),
                      title: Text("Privacy Policy",
                          style: TextStyle(color: Colors.white70)),
                      onTap: () => Navigator.pop(ctx),
                    ),
                    ListTile(
                      leading:
                          Icon(Icons.restart_alt, color: Colors.orangeAccent),
                      title: Text("Replay Tutorial",
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
      body: Consumer<SensorManager>(
        builder: (context, manager, child) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Mining Status & Earnings
                  _buildMiningMainCard(manager),

                  SizedBox(height: 16),

                  // 2. Network Stats (Placeholder/Mock for momentum)
                  _buildNetworkStats(),

                  SizedBox(height: 24),

                  // 3. Data Metrics
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

  Widget _buildNetworkStats() {
    return Row(
      children: [
        _buildSmallStat('Nodes', '6', Icons.hub_outlined),
        SizedBox(width: 8),
        _buildSmallStat('Uptime', '99.9%', Icons.timer_outlined),
        SizedBox(width: 8),
        _buildSmallStat('Latency', '88ms', Icons.bolt),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiningMainCard(SensorManager manager) {
    bool isSampling = manager.isSampling;
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: isSampling
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.white10),
        boxShadow: [
          if (isSampling)
            BoxShadow(
                color: Colors.greenAccent.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED EARNINGS',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            manager.totalEarnings.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('QBIT',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("About QBIT Rewards"),
                              content: Text(
                                  "QBIT is the native reward token of the DiSensor network.\n\n"
                                  "You earn QBIT by contributing valid sensor data (Pressure, Noise, Location). "
                                  "Future value will be determined by network usage and data demand.\n\n"
                                  "Mining Rate: Base + Movement Bonus."),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text("GOT IT"))
                              ],
                            ),
                          );
                        },
                        child: Icon(Icons.info_outline,
                            color: Colors.white24, size: 16),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(Icons.token_outlined,
                        color: Colors.greenAccent, size: 32),
                  ),
                ],
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
                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white)),
                          SizedBox(width: 16),
                          Text('Checking permissions...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.blue.shade700,
                    ));

                    bool granted = await manager.requestPermissions();

                    if (granted) {
                      // Permissions granted, start immediately
                      await manager.startRealSampling(
                          deviceId: deviceId ?? "DEVICE-1");

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('✅ Mining started successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ));
                    } else {
                      // Check what went wrong
                      bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      LocationPermission perm =
                          await Geolocator.checkPermission();

                      String message =
                          '📍 Location permission is required for mining.';
                      bool showSettings = false;

                      if (!serviceEnabled) {
                        message =
                            '📍 Please turn ON GPS/Location in device settings.';
                      } else if (perm == LocationPermission.deniedForever) {
                        message =
                            '⚠️ Location permanently denied. Tap SETTINGS to enable.';
                        showSettings = true;
                      } else if (perm == LocationPermission.denied) {
                        message =
                            '📍 Please allow location access when prompted.';
                      }

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message),
                        backgroundColor:
                            showSettings ? Colors.orange : Colors.redAccent,
                        duration: Duration(seconds: 5),
                        action: showSettings
                            ? SnackBarAction(
                                label: 'SETTINGS',
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
                child: Text(isSampling ? 'PAUSE MINING' : 'RESUME MINING',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, String unit, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Show explanation based on title
        String explanation = "Real-time sensor reading.";
        if (title.contains("Pressure")) {
          explanation =
              "Atmospheric pressure helps in calculating altitude and predicting local weather system changes.";
        } else if (title.contains("Noise")) {
          explanation =
              "Ambient noise level monitoring contributes to urban noise pollution mapping.";
        }

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Row(children: [
              Icon(icon, color: color),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white))
            ]),
            content: Text(explanation, style: TextStyle(color: Colors.white70)),
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
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
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
    bool isActivated =
        manager.inviterId != null && manager.inviterId!.isNotEmpty;

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
                Text("BOOST ACTIVE",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Referred by: ${manager.inviterId}",
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
              child: Text("+20% Mining Efficiency",
                  style: TextStyle(color: Colors.white, fontSize: 10)),
            )
          ],
        ),
      );
    }

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
            onPressed: () async {
              if (_tempInviteCode != null && _tempInviteCode!.length == 6) {
                manager.inviterId = _tempInviteCode;
                // Simple persistence hack for this session
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('inviter_code', _tempInviteCode!);

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
