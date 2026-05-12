import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/models/listing_filter_model.dart';
import '../../domain/models/listing_model.dart';

class ListingRemoteDataSource {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Listing>> getListings(ListingFilter filter) async {
    var query = _client.from('listings').select().eq('status', 'active');

    if (filter.assetType != null) {
      query = query.eq('asset_type', filter.assetType!);
    }
    if (filter.region != null) {
      query = query.eq('region', filter.region!);
    }
    if (filter.province != null) {
      query = query.eq('province', filter.province!);
    }
    if (filter.minAreaM2 != null) {
      query = query.gte('total_area_m2', filter.minAreaM2!);
    }
    if (filter.maxAreaM2 != null) {
      query = query.lte('total_area_m2', filter.maxAreaM2!);
    }
    if (filter.maxPriceUsd != null) {
      query = query.lte('lease_price_usd', filter.maxPriceUsd!);
    }

    final data = switch (filter.sortBy) {
      'price_asc' => await query.order('lease_price_usd', ascending: true),
      'price_desc' => await query.order('lease_price_usd', ascending: false),
      'newest' => await query.order('created_at', ascending: false),
      'area_asc' => await query.order('total_area_m2', ascending: true),
      _ => await query
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false),
    };

    var listings = data.map((e) => Listing.fromMap(e)).toList();

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final q = filter.searchQuery!.toLowerCase();
      listings = listings
          .where((l) =>
              l.title.toLowerCase().contains(q) ||
              l.province.toLowerCase().contains(q) ||
              (l.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return listings;
  }

  Future<List<Listing>> getFeaturedListings() async {
    final data = await _client
        .from('listings')
        .select()
        .eq('status', 'active')
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(6);

    return data.map((e) => Listing.fromMap(e)).toList();
  }

  Future<Listing?> getListingById(String id) async {
    final data = await _client
        .from('listings')
        .select()
        .eq('id', id)
        .maybeSingle();

    return data != null ? Listing.fromMap(data) : null;
  }

  Future<Listing?> getListingBySlug(String slug) async {
    final data = await _client
        .from('listings')
        .select()
        .eq('slug', slug)
        .maybeSingle();

    return data != null ? Listing.fromMap(data) : null;
  }

  Future<void> incrementViews(String listingId) async {
    await _client.rpc(
      'increment_listing_views',
      params: {'listing_id': listingId},
    );
  }

  Future<List<Listing>> getSavedListings(String userId) async {
    final data = await _client
        .from('saved_listings')
        .select('listing_id, listings(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data
        .map((e) => Listing.fromMap(e['listings'] as Map<String, dynamic>))
        .toList();
  }

  Future<bool> isListingSaved(String userId, String listingId) async {
    final data = await _client
        .from('saved_listings')
        .select('id')
        .eq('user_id', userId)
        .eq('listing_id', listingId)
        .maybeSingle();

    return data != null;
  }

  Future<void> saveListing(String userId, String listingId) async {
    await _client.from('saved_listings').upsert({
      'user_id': userId,
      'listing_id': listingId,
    });
  }

  Future<void> unsaveListing(String userId, String listingId) async {
    await _client
        .from('saved_listings')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
  }

  Future<List<Map<String, String>>> getIndustrialZoneOptions() async {
    final data = await _client
        .from('industrial_zones')
        .select('id, name')
        .eq('is_active', true)
        .order('name');
    return (data as List)
        .map((e) => {'id': e['id'] as String, 'name': e['name'] as String})
        .toList();
  }

  Future<List<Listing>> getMyListings(String userId) async {
    final data = await _client
        .from('listings')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return data.map((e) => Listing.fromMap(e)).toList();
  }

  Future<String> createListing(Map<String, dynamic> data) async {
    final result = await _client
        .from('listings')
        .insert(data)
        .select('id')
        .single();
    return result['id'] as String;
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _client.from('listings').update(data).eq('id', id);
  }

  Future<void> deleteListing(String id) async {
    await _client.from('listings').delete().eq('id', id);
  }

  Future<void> submitInquiry({
    required String listingId,
    String? userId,
    required String name,
    required String email,
    String? phone,
    String? company,
    String? message,
    double? requiredAreaM2,
    DateTime? moveInDate,
  }) async {
    await _client.from('listing_inquiries').insert({
      'listing_id': listingId,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'message': message,
      'required_area_m2': requiredAreaM2,
      'move_in_date': moveInDate?.toIso8601String().split('T').first,
    });
  }
}
