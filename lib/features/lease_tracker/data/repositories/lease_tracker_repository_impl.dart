import '../../domain/models/lease_rate_model.dart';
import '../../domain/models/market_insight_model.dart';
import '../../domain/models/rate_alert_model.dart';
import '../../domain/repositories/lease_tracker_repository.dart';
import '../datasources/lease_tracker_remote_datasource.dart';

class LeaseTrackerRepositoryImpl implements LeaseTrackerRepository {
  final LeaseTrackerRemoteDataSource _dataSource;

  LeaseTrackerRepositoryImpl(this._dataSource);

  @override
  Future<List<LeaseRate>> getRates({
    String? zone,
    String? province,
    String? region,
    String? assetType,
  }) =>
      _dataSource.getRates(
          zone: zone, province: province, region: region, assetType: assetType);

  @override
  Future<List<LeaseRate>> getRateHistory(String zoneName, String assetType) =>
      _dataSource.getRateHistory(zoneName, assetType);

  @override
  Future<List<RateAlert>> getUserAlerts(String userId) =>
      _dataSource.getUserAlerts(userId);

  @override
  Future<void> createAlert(RateAlert alert) => _dataSource.createAlert(alert);

  @override
  Future<void> toggleAlert(String alertId, bool isActive) =>
      _dataSource.toggleAlert(alertId, isActive);

  @override
  Future<void> deleteAlert(String alertId) => _dataSource.deleteAlert(alertId);

  @override
  Future<List<MarketInsight>> getInsights() => _dataSource.getInsights();
}
