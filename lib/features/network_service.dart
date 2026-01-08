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

  /// Measures latency to a reliable target in milliseconds.
  /// Returns -1 if request fails.
  Future<int> measureLatency() async {
    final stopwatch = Stopwatch()..start();
    try {
      // Use generate_204 endpoints which are designed for connectivity checks
      // These are faster and don't redirect
      final response = await http
          .get(
            Uri.parse('http://connectivitycheck.gstatic.com/generate_204'),
          )
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();

      // Accept 204 (expected) or any non-error status
      if (response.statusCode < 400) {
        return stopwatch.elapsedMilliseconds;
      }
      return -1;
    } catch (e) {
      // Fallback: Try alternate endpoint
      try {
        final fallbackStopwatch = Stopwatch()..start();
        final fallbackResponse = await http
            .get(
              Uri.parse('http://www.gstatic.com/generate_204'),
            )
            .timeout(const Duration(seconds: 5));
        fallbackStopwatch.stop();

        if (fallbackResponse.statusCode < 400) {
          return fallbackStopwatch.elapsedMilliseconds;
        }
      } catch (_) {
        // Both failed
      }
      return -1;
    }
  }
}
