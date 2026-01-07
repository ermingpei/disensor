import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiScannerService {
  /// Start a WiFi scan if permission is granted.
  /// Returns true if scan was successfully triggered.
  Future<bool> startScan() async {
    // WiFi scanning is primarily for Android.
    if (!Platform.isAndroid) return false;

    try {
      // 1. Check if we can scan
      CanStartScan can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        debugPrint("⚠️ Cannot start WiFi scan: $can");
        return false;
      }

      // 2. Start Scan
      final success = await WiFiScan.instance.startScan();
      debugPrint("🚀 WiFi Scan Triggered: $success");
      return success;
    } catch (e) {
      debugPrint("❌ WiFi Scan Error: $e");
      return false;
    }
  }

  /// Get the results of the latest scan.
  /// Returns a list of maps containing key fingerprint data.
  Future<List<Map<String, dynamic>>> getScannedResults() async {
    if (Platform.isIOS) {
      return _getIosCurrentWifi();
    }

    if (!Platform.isAndroid) return [];

    try {
      // 1. Get Scanned Results
      // This reads from the OS cache populated by startScan()
      final results = await WiFiScan.instance.getScannedResults();

      if (results.isEmpty) {
        debugPrint("📡 No WiFi networks found in scan results.");
        return [];
      }

      debugPrint("📡 Found ${results.length} WiFi networks");

      // 2. Map to simplified JSON structure
      return results.map((accessPoint) {
        return {
          'bssid': accessPoint.bssid,
          'ssid': accessPoint.ssid,
          'rssi': accessPoint.level, // Signal strength in dBm
          'frequency': accessPoint.frequency, // Channel frequency in MHz
          'capabilities': accessPoint.capabilities,
          'timestamp': DateTime.now().toIso8601String(), // Timestamp of fetch
        };
      }).toList();
    } catch (e) {
      debugPrint("❌ Failed to get WiFi results: $e");
      return [];
    }
  }

  /// iOS Fallback: Get current WiFi info
  Future<List<Map<String, dynamic>>> _getIosCurrentWifi() async {
    try {
      final info = NetworkInfo();
      String? bssid = await info.getWifiBSSID();
      String? ssid = await info.getWifiName();

      if (bssid == null) {
        debugPrint(
            "⚠️ iOS: No WiFi BSSID found (Permission issue or not connected)");
        return [];
      }

      debugPrint("📡 iOS: Found current WiFi: $ssid ($bssid)");

      return [
        {
          'bssid': bssid,
          'ssid': ssid,
          'rssi': 0, // Not available on iOS
          'frequency': 0, // Not available on iOS
          'capabilities': 'ios_current_connection',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];
    } catch (e) {
      debugPrint("❌ iOS WiFi check failed: $e");
      return [];
    }
  }
}
