import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../site_selection/domain/models/industrial_zone_model.dart';
import '../../../lease_tracker/domain/models/lease_rate_model.dart';

final publicZonesProvider = FutureProvider<List<IndustrialZone>>((ref) async {
  final data = await SupabaseConfig.client
      .from('industrial_zones')
      .select()
      .eq('is_active', true)
      .order('is_featured', ascending: false)
      .order('created_at', ascending: false)
      .limit(6);
  return (data as List).map((e) => IndustrialZone.fromMap(e)).toList();
});

final publicLeaseRatesProvider = FutureProvider<List<LeaseRate>>((ref) async {
  final data = await SupabaseConfig.client
      .from('lease_rates')
      .select()
      .order('recorded_month', ascending: false)
      .limit(5);
  return (data as List).map((e) => LeaseRate.fromMap(e)).toList();
});

final publicSearchQueryProvider = StateProvider<String?>((ref) => null);
final publicRegionFilterProvider = StateProvider<String?>((ref) => null);

final publicSearchResultsProvider =
    FutureProvider<List<IndustrialZone>>((ref) async {
  final region = ref.watch(publicRegionFilterProvider);
  final industry = ref.watch(publicSearchQueryProvider);

  var query = SupabaseConfig.client
      .from('industrial_zones')
      .select()
      .eq('is_active', true);

  if (region != null && region.isNotEmpty) {
    query = query.eq('region', region);
  }
  if (industry != null && industry.isNotEmpty) {
    query = query.contains('industries_supported', [industry]);
  }

  final data = await query.order('is_featured', ascending: false).limit(10);
  return (data as List).map((e) => IndustrialZone.fromMap(e)).toList();
});
