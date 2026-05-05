import '../models/industrial_zone_model.dart';
import '../models/site_selection_query_model.dart';

abstract class SiteSelectionRepository {
  Future<List<IndustrialZone>> getAllZones();
  Future<List<IndustrialZone>> searchZones(SiteSelectionQuery query);
  Future<void> saveResult(
    String userId,
    SiteSelectionQuery query,
    List<IndustrialZone> results,
  );
  Future<List<Map<String, dynamic>>> getSavedResults(String userId);
  Future<void> saveContactLead(String? userId, IndustrialZone zone);
}
