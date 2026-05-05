import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/industrial_zone_model.dart';
import '../../domain/models/site_selection_query_model.dart';

class SiteSelectionRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<IndustrialZone>> getAllZones() async {
    final data = await _client
        .from('industrial_zones')
        .select()
        .eq('is_active', true)
        .order('is_featured', ascending: false)
        .order('name');
    return data.map((e) => IndustrialZone.fromMap(e)).toList();
  }

  Future<List<IndustrialZone>> searchZones(SiteSelectionQuery query) async {
    final data = await _client
        .from('industrial_zones')
        .select()
        .eq('is_active', true);

    final requiredHa = query.requiredAreaM2 / 10000;

    return data
        .map((e) => IndustrialZone.fromMap(e))
        .where((zone) {
          if (query.preferredRegion != null) {
            if (zone.region != query.preferredRegion) return false;
          }
          if (query.preferredProvinces.isNotEmpty) {
            if (!query.preferredProvinces.contains(zone.province)) return false;
          }
          if ((zone.availableAreaHa ?? 0) < requiredHa) return false;
          if (query.maxBudgetUsd != null && zone.leasePriceUsd != null) {
            if (zone.leasePriceUsd! > query.maxBudgetUsd!) return false;
          }
          return true;
        })
        .toList();
  }

  Future<void> saveResult(
    String userId,
    SiteSelectionQuery query,
    List<IndustrialZone> results,
  ) async {
    await _client.from('site_selection_results').insert({
      'user_id': userId,
      'query_input': query.toJson(),
      'results': results.map((z) => z.toMap()).toList(),
    });
  }

  Future<List<Map<String, dynamic>>> getSavedResults(String userId) async {
    final data = await _client
        .from('site_selection_results')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> saveContactLead(String? userId, IndustrialZone zone) async {
    await _client.from('contact_leads').insert({
      'user_id': userId,
      'zone_id': zone.id,
      'zone_name': zone.name,
    });
  }
}
