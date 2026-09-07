/// Supabase configuration constants and table definitions for TarlingBook.
class SupabaseConstants {
  SupabaseConstants._();

  // Supabase Project Credentials (production live)
  static const String defaultUrl = 'https://mroaufpygdxrfucixtju.supabase.co';
  static const String defaultAnonKey = 'sb_publishable_b2nlP2qo6GLSN_dY50JkFw_2QSVV6a3';

  // Table Names
  static const String tableUsers = 'users';
  static const String tableCategories = 'categories';
  static const String tableCities = 'cities';
  static const String tableDistricts = 'districts';
  static const String tableSettings = 'settings';
  static const String tableArtistProfiles = 'artist_profiles';
  static const String tablePackages = 'packages';
  static const String tableZonePrices = 'zone_prices';
  static const String tablePortfolios = 'portfolios';
  static const String tableBlockedDates = 'blocked_dates';
  static const String tableBookings = 'bookings';
  static const String tableBookingOffers = 'booking_offers';
  static const String tableMessages = 'messages';
  static const String tableBookingItems = 'booking_items';
  static const String tableBookingStatusHistories = 'booking_status_histories';
  static const String tablePayments = 'payments';
  static const String tableRefunds = 'refunds';
  static const String tableDisputes = 'disputes';
  static const String tablePayouts = 'payouts';
  static const String tableReviews = 'reviews';
  static const String tableOtps = 'otps';
  static const String tableNotifications = 'notifications';
  static const String tableBotConversations = 'bot_conversations';
  static const String tableBotFaqTemplates = 'bot_faq_templates';

  // Views
  static const String viewArtistPublic = 'artist_public';

  // Storage Buckets
  static const String bucketArtistPhotos = 'artist-photos';
  static const String bucketKtpVerifications = 'ktp-verifications';
  static const String bucketCashReceipts = 'cash-receipts';
  static const String bucketDisputeEvidences = 'dispute-evidences';

  // Edge Functions
  static const String fnCreateBooking = 'create-booking';
  static const String fnBotEngine = 'bot-engine';
}
