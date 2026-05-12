import '../../domain/models/listing_filter_model.dart';
import '../../domain/models/listing_model.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_datasource.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingRemoteDataSource _dataSource;

  ListingRepositoryImpl(this._dataSource);

  @override
  Future<List<Listing>> getListings(ListingFilter filter) =>
      _dataSource.getListings(filter);

  @override
  Future<List<Listing>> getFeaturedListings() =>
      _dataSource.getFeaturedListings();

  @override
  Future<Listing?> getListingById(String id) =>
      _dataSource.getListingById(id);

  @override
  Future<Listing?> getListingBySlug(String slug) =>
      _dataSource.getListingBySlug(slug);

  @override
  Future<void> incrementViews(String listingId) =>
      _dataSource.incrementViews(listingId);

  @override
  Future<List<Listing>> getSavedListings(String userId) =>
      _dataSource.getSavedListings(userId);

  @override
  Future<void> saveListing(String userId, String listingId) =>
      _dataSource.saveListing(userId, listingId);

  @override
  Future<void> unsaveListing(String userId, String listingId) =>
      _dataSource.unsaveListing(userId, listingId);

  @override
  Future<List<Map<String, String>>> getIndustrialZoneOptions() =>
      _dataSource.getIndustrialZoneOptions();

  @override
  Future<List<Listing>> getMyListings(String userId) =>
      _dataSource.getMyListings(userId);

  @override
  Future<String> createListing(Map<String, dynamic> data) =>
      _dataSource.createListing(data);

  @override
  Future<void> updateListing(String id, Map<String, dynamic> data) =>
      _dataSource.updateListing(id, data);

  @override
  Future<void> deleteListing(String id) => _dataSource.deleteListing(id);

  @override
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
  }) =>
      _dataSource.submitInquiry(
        listingId: listingId,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        company: company,
        message: message,
        requiredAreaM2: requiredAreaM2,
        moveInDate: moveInDate,
      );
}
