import '../models/lease_rate_model.dart';
import '../models/market_insight_model.dart';
import '../models/rate_alert_model.dart';

abstract class LeaseTrackerRepository {
  Future<List<LeaseRate>> getRates({
    String? zone,
    String? province,
    String? region,
    String? assetType,
  });

  Future<List<LeaseRate>> getRateHistory(String zoneName, String assetType);

  Future<List<RateAlert>> getUserAlerts(String userId);

  Future<void> createAlert(RateAlert alert);

  Future<void> toggleAlert(String alertId, bool isActive);

  Future<void> deleteAlert(String alertId);

  Future<List<MarketInsight>> getInsights();
}
