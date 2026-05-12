import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/listing_remote_datasource.dart';
import '../../data/repositories/listing_repository_impl.dart';
import '../../domain/models/listing_filter_model.dart';
import '../../domain/models/listing_model.dart';
import '../../domain/repositories/listing_repository.dart';

final listingDataSourceProvider = Provider<ListingRemoteDataSource>((ref) {
  return ListingRemoteDataSource();
});

final listingRepositoryProvider = Provider<ListingRepository>((ref) {
  return ListingRepositoryImpl(ref.watch(listingDataSourceProvider));
});

final listingFilterProvider = StateProvider<ListingFilter>((ref) {
  return const ListingFilter();
});

final selectedAssetTypeProvider = StateProvider<String?>((ref) => null);
final selectedRegionProvider = StateProvider<String?>((ref) => null);

final listingsProvider = FutureProvider<List<Listing>>((ref) {
  final filter = ref.watch(listingFilterProvider);
  return ref.watch(listingRepositoryProvider).getListings(filter);
});

final featuredListingsProvider = FutureProvider<List<Listing>>((ref) {
  return ref.watch(listingRepositoryProvider).getFeaturedListings();
});

final savedListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(listingRepositoryProvider).getSavedListings(user.id);
});

final isListingSavedProvider =
    FutureProvider.family<bool, String>((ref, listingId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return ref
      .watch(listingDataSourceProvider)
      .isListingSaved(user.id, listingId);
});

final listingByIdProvider =
    FutureProvider.family<Listing?, String>((ref, id) {
  return ref.watch(listingRepositoryProvider).getListingById(id);
});

final listingBySlugProvider =
    FutureProvider.family<Listing?, String>((ref, slug) {
  return ref.watch(listingRepositoryProvider).getListingBySlug(slug);
});

final myListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(listingDataSourceProvider).getMyListings(user.id);
});

final industrialZoneOptionsProvider =
    FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(listingRepositoryProvider).getIndustrialZoneOptions();
});

// (excludeId, assetType, region)
final similarListingsProvider =
    FutureProvider.family<List<Listing>, (String, String, String)>(
        (ref, params) async {
  final (excludeId, assetType, region) = params;
  final all = await ref.read(listingRepositoryProvider).getListings(
        ListingFilter(assetType: assetType, region: region),
      );
  return all.where((l) => l.id != excludeId).take(4).toList();
});
