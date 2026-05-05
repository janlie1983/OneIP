import '../../domain/models/industrial_zone_model.dart';
import '../../domain/models/site_selection_query_model.dart';
import '../../domain/repositories/site_selection_repository.dart';
import '../datasources/site_selection_remote_datasource.dart';

class SiteSelectionRepositoryImpl implements SiteSelectionRepository {
  final SiteSelectionRemoteDataSource _dataSource;

  SiteSelectionRepositoryImpl(this._dataSource);

  @override
  Future<List<IndustrialZone>> getAllZones() => _dataSource.getAllZones();

  @override
  Future<List<IndustrialZone>> searchZones(SiteSelectionQuery query) =>
      _dataSource.searchZones(query);

  @override
  Future<void> saveResult(
    String userId,
    SiteSelectionQuery query,
    List<IndustrialZone> results,
  ) =>
      _dataSource.saveResult(userId, query, results);

  @override
  Future<List<Map<String, dynamic>>> getSavedResults(String userId) =>
      _dataSource.getSavedResults(userId);

  @override
  Future<void> saveContactLead(String? userId, IndustrialZone zone) =>
      _dataSource.saveContactLead(userId, zone);
}
