import 'package:supabase_flutter/supabase_flutter.dart';
import 'privacy_guard.dart';

/// 负责将端侧脱敏后的数据同步至 Supabase 的服务类。
class DataSyncService {
  final SupabaseClient _client;
  final PrivacyGuard _privacyGuard;

  DataSyncService({
    required SupabaseClient client,
    required PrivacyGuard privacyGuard,
  })  : _client = client,
        _privacyGuard = privacyGuard;

  /// 上报传感器读数
  Future<void> uploadReading({
    required String deviceId,
    required double pressure,
    required double decibel,
    required double lat,
    required double lng,
    String? referredBy,
    String? networkType,
    int? latency,
  }) async {
    final timestamp = DateTime.now().toUtc();
    final anonymizedId = _privacyGuard.anonymizeNodeId(deviceId);
    final perturbedLoc = _privacyGuard.perturbLocation(lat, lng);

    // 生成数据摘要以供云端验证一致性
    final digest = _privacyGuard.generateDigest(
      pressure: pressure,
      decibel: decibel,
      lat: perturbedLoc['lat']!,
      lng: perturbedLoc['lng']!,
      timestamp: timestamp.millisecondsSinceEpoch,
    );

    // 1. 确保节点已注册 (Upsert)
    Map<String, dynamic> nodeData = {
      'anonymized_id': anonymizedId,
      'device_model': 'Mobile-PoC',
    };
    if (referredBy != null && referredBy.isNotEmpty) {
      nodeData['referred_by'] = referredBy;
    }

    await _client.from('nodes').upsert(nodeData, onConflict: 'anonymized_id');

    // 2. 插入读数
    final Map<String, dynamic> readingData = {
      'node_id': anonymizedId,
      'pressure_hpa': pressure,
      'decibel_db': decibel,
      'location': 'POINT(${perturbedLoc['lng']} ${perturbedLoc['lat']})',
      'timestamp': timestamp.toIso8601String(),
      'digest': digest,
    };

    // Add extra params if available
    if (networkType != null) readingData['network_type'] = networkType;
    if (latency != null) readingData['latency_ms'] = latency;

    await _client.from('readings').insert(readingData);
  }
}
