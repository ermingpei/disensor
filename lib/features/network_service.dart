import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Returns the current network type as a readable string
  Future<String> getNetworkType() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      if (results.isEmpty) return 'None';

      // We take the first result as primary for now
      final result = results.first;

      switch (result) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Mobile'; // In a real app we might differentiate 4G/5G if platform allows,
        // but standard connectivity_plus just says mobile.
        // We can potentially use other packages for 5G detection later.
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.none:
          return 'None';
        default:
          return 'Other';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Measures latency to a reliable target (Cloudflare DNS) in milliseconds.
  /// Returns -1 if request fails.
  Future<int> measureLatency() async {
    final stopwatch = Stopwatch()..start();
    try {
      // 1.1.1.1 is Cloudflare's DNS, usually very fast and reliable.
      // We use HEAD to minimize data usage.
      final response = await http.head(Uri.parse('https://1.1.1.1'));
      stopwatch.stop();
      if (response.statusCode == 200) {
        return stopwatch.elapsedMilliseconds;
      }
      return -1;
    } catch (e) {
      return -1;
    }
  }
}
