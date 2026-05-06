abstract class AppPermission {
  // Super Admin
  static const String manageUsers = 'manage_users';
  static const String managePlatform = 'manage_platform';
  static const String viewBilling = 'view_billing';
  static const String impersonateUser = 'impersonate_user';

  // Admin / Moderator
  static const String verifyUsers = 'verify_users';
  static const String manageKyc = 'manage_kyc';
  static const String moderateListings = 'moderate_listings';
  static const String flagContent = 'flag_content';
  static const String viewAnalytics = 'view_analytics';

  // Supply (Property Owner / Broker)
  static const String manageListings = 'manage_listings';
  static const String createListing = 'create_listing';
  static const String manageOwnListings = 'manage_own_listings';
  static const String viewInquiries = 'view_inquiries';
  static const String viewAnalyticsOwn = 'view_analytics_own';

  // Demand (Corporate / SME / Guest)
  static const String searchListings = 'search_listings';
  static const String viewContactFull = 'view_contact_full';
  static const String saveShortlist = 'save_shortlist';
  static const String viewMarketReport = 'view_market_report';
  static const String setPriceAlert = 'set_price_alert';
  static const String multiSeat = 'multi_seat';
}
