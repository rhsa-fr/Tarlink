abstract class AdminRepository {
  Future<List<Map<String, dynamic>>> getPendingVerifications();
  Future<void> approveArtist(String artistId);
  Future<void> rejectArtist(String artistId);

  Future<List<Map<String, dynamic>>> getDisputes();
  Future<void> resolveDispute({
    required String disputeId,
    required String bookingId,
    required String verdict,
    required bool refundToCustomer,
  });

  Future<List<Map<String, dynamic>>> getFailedPayouts();
  Future<void> retryPayout(String payoutId);

  Future<List<Map<String, dynamic>>> getAllArtists();
  Future<void> toggleSuspendArtist(String artistId, bool isSuspended);
}
