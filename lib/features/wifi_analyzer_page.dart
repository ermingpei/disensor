import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../core/app_strings.dart';

/// WiFi Analyzer Page - Scan and display nearby WiFi networks
class WiFiAnalyzerPage extends StatefulWidget {
  const WiFiAnalyzerPage({super.key});

  @override
  State<WiFiAnalyzerPage> createState() => _WiFiAnalyzerPageState();
}

class _WiFiAnalyzerPageState extends State<WiFiAnalyzerPage> {
  List<WiFiAccessPoint> _accessPoints = [];
  bool _isScanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final can = await WiFiScan.instance.canStartScan();
      if (can == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
        final results = await WiFiScan.instance.getScannedResults();
        setState(() {
          _accessPoints = results;
          _accessPoints.sort((a, b) => b.level.compareTo(a.level));
        });
      } else {
        setState(() {
          _error = 'Cannot scan WiFi: $can';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Color _getSignalColor(int level) {
    if (level >= -50) return Colors.green;
    if (level >= -60) return Colors.lightGreen;
    if (level >= -70) return Colors.yellow;
    if (level >= -80) return Colors.orange;
    return Colors.red;
  }

  String _getSignalQuality(int level) {
    if (level >= -50) return AppStrings.t('signal_excellent');
    if (level >= -60) return AppStrings.t('signal_good');
    if (level >= -70) return AppStrings.t('signal_fair');
    return AppStrings.t('signal_poor');
  }

  int _getSignalBars(int level) {
    if (level >= -50) return 4;
    if (level >= -60) return 3;
    if (level >= -70) return 2;
    if (level >= -80) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.t('wifi_analyzer')),
        actions: [
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D9B), Color(0xFF1A4A5E)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    Icons.wifi,
                    '${_accessPoints.length}',
                    AppStrings.t('networks_found'),
                  ),
                  _buildSummaryItem(
                    Icons.signal_wifi_4_bar,
                    _accessPoints.isNotEmpty
                        ? '${_accessPoints.first.level} dBm'
                        : '--',
                    AppStrings.t('strongest_signal'),
                  ),
                ],
              ),
            ),

            // Network List
            Expanded(
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(_error!,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _startScan,
                            child: Text(AppStrings.t('retry')),
                          ),
                        ],
                      ),
                    )
                  : _accessPoints.isEmpty && !_isScanning
                      ? Center(
                          child: Text(
                            AppStrings.t('no_networks'),
                            style: const TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _accessPoints.length,
                          itemBuilder: (context, index) {
                            final ap = _accessPoints[index];
                            final signalColor = _getSignalColor(ap.level);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E3F),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: signalColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Signal Bars
                                  _buildSignalBars(
                                      _getSignalBars(ap.level), signalColor),
                                  const SizedBox(width: 16),
                                  // Network Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ap.ssid.isNotEmpty
                                              ? ap.ssid
                                              : '<Hidden>',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ch ${ap.frequency ~/ 1000 < 3 ? (ap.frequency - 2407) ~/ 5 : (ap.frequency - 5000) ~/ 5} • ${ap.frequency} MHz',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Signal Strength
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${ap.level} dBm',
                                        style: TextStyle(
                                          color: signalColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _getSignalQuality(ap.level),
                                        style: TextStyle(
                                          color: signalColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSignalBars(int bars, Color color) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index < bars;
        return Container(
          width: 6,
          height: 8.0 + (index * 6),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? color : Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
