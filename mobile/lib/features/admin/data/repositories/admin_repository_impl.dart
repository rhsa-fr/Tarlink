import '../../../../core/network/api_client.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl([dynamic _]);

  @override
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    try {
      final res = await ApiClient.get('/admin/verifications');
      if (res is List) {
        return res.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> approveArtist(String artistId) async {
    await ApiClient.post('/admin/verifications', body: {
      'artistId': artistId,
      'status': 'verified',
    });
  }

  @override
  Future<void> rejectArtist(String artistId) async {
    await ApiClient.post('/admin/verifications', body: {
      'artistId': artistId,
      'status': 'suspended',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getDisputes() async {
    try {
      final res = await ApiClient.get('/admin/disputes');
      if (res is List) {
        return res.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> resolveDispute({
    required String disputeId,
    required String bookingId,
    required String verdict,
    required bool refundToCustomer,
  }) async {
    await ApiClient.post('/admin/disputes', body: {
      'disputeId': disputeId,
      'verdict': verdict,
      'action': refundToCustomer ? 'refund_customer' : 'release_group',
    });
  }

  @override
  Future<void> toggleSuspendArtist(String artistId, bool isSuspended) async {
    await ApiClient.post('/admin/verifications', body: {
      'artistId': artistId,
      'status': isSuspended ? 'suspended' : 'verified',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getAllArtists() async {
    try {
      final res = await ApiClient.get('/admin/verifications');
      if (res is List) {
        return res.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getFailedPayouts() async {
    try {
      final res = await ApiClient.get('/admin/payouts?status=failed');
      if (res is List) {
        return res.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> retryPayout(String payoutId) async {
    await ApiClient.post('/admin/payouts', body: {
      'payoutId': payoutId,
      'action': 'retry',
    });
  }
}
