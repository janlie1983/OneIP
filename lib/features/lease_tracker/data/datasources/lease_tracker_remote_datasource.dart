import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/lease_rate_model.dart';
import '../../domain/models/market_insight_model.dart';
import '../../domain/models/rate_alert_model.dart';

class LeaseTrackerRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<LeaseRate>> getRates({
    String? zone,
    String? province,
    String? region,
    String? assetType,
  }) async {
    final data = await _client
        .from('lease_rates')
        .select()
        .order('recorded_month', ascending: false);

    return data
        .map((e) => LeaseRate.fromMap(e))
        .where((r) {
          if (zone != null && r.zoneName != zone) return false;
          if (province != null && r.province != province) return false;
          if (region != null && r.region != region) return false;
          if (assetType != null && r.assetType != assetType) return false;
          return true;
        })
        .toList();
  }

  Future<List<LeaseRate>> getRateHistory(
      String zoneName, String assetType) async {
    final data = await _client
        .from('lease_rates')
        .select()
        .eq('zone_name', zoneName)
        .eq('asset_type', assetType)
        .order('recorded_month', ascending: true);

    return data.map((e) => LeaseRate.fromMap(e)).toList();
  }

  Future<List<RateAlert>> getUserAlerts(String userId) async {
    final data = await _client
        .from('rate_alerts')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data.map((e) => RateAlert.fromMap(e)).toList();
  }

  Future<void> createAlert(RateAlert alert) async {
    await _client.from('rate_alerts').insert(alert.toInsertMap());
  }

  Future<void> toggleAlert(String alertId, bool isActive) async {
    await _client
        .from('rate_alerts')
        .update({'is_active': isActive})
        .eq('id', alertId);
  }

  Future<void> deleteAlert(String alertId) async {
    await _client.from('rate_alerts').delete().eq('id', alertId);
  }

  Future<List<MarketInsight>> getInsights() async {
    final data = await _client
        .from('market_insights')
        .select()
        .order('published_at', ascending: false);

    return data.map((e) => MarketInsight.fromMap(e)).toList();
  }
}
