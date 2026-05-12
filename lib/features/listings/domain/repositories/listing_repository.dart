import '../models/listing_model.dart';
import '../models/listing_filter_model.dart';

abstract class ListingRepository {
  Future<List<Listing>> getListings(ListingFilter filter);
  Future<List<Listing>> getFeaturedListings();
  Future<Listing?> getListingById(String id);
  Future<Listing?> getListingBySlug(String slug);
  Future<void> incrementViews(String listingId);
  Future<List<Listing>> getSavedListings(String userId);
  Future<void> saveListing(String userId, String listingId);
  Future<void> unsaveListing(String userId, String listingId);
  Future<List<Map<String, String>>> getIndustrialZoneOptions();
  Future<List<Listing>> getMyListings(String userId);
  Future<String> createListing(Map<String, dynamic> data);
  Future<void> updateListing(String id, Map<String, dynamic> data);
  Future<void> deleteListing(String id);
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
  });
}
