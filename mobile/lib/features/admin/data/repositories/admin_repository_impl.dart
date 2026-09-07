import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _client;

  AdminRepositoryImpl(this._client);

  @override
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    final data = await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .select('id, display_name, category, base_city, base_district, created_at, users (name, phone)')
        .eq('status', 'pending');

    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> approveArtist(String artistId) async {
    final updated = await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .update({'status': 'verified'})
        .eq('id', artistId)
        .select('user_id')
        .maybeSingle();

    if (updated != null && updated['user_id'] != null) {
      await _client
          .from(SupabaseConstants.tableUsers)
          .update({'role': 'group_leader'})
          .eq('id', updated['user_id']);
    }
  }

  @override
  Future<void> rejectArtist(String artistId) async {
    await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .update({'status': 'rejected'})
        .eq('id', artistId);
  }

  @override
  Future<List<Map<String, dynamic>>> getDisputes() async {
    final data = await _client
        .from(SupabaseConstants.tableDisputes)
        .select('id, booking_id, reporter_id, reason, status, evidence_urls, created_at, bookings (code, total_price)')
        .eq('status', 'open');

    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> resolveDispute({
    required String disputeId,
    required String bookingId,
    required String verdict,
    required bool refundToCustomer,
  }) async {
    // 1. Update dispute status
    await _client.from(SupabaseConstants.tableDisputes).update({
      'status': 'resolved',
      'verdict': verdict,
    }).eq('id', disputeId);

    // 2. Adjust payout based on admin verdict
    if (refundToCustomer) {
      await _client
          .from(SupabaseConstants.tablePayouts)
          .update({'status': 'CANCELLED'})
          .eq('booking_id', bookingId);

      await _client
          .from(SupabaseConstants.tableBookings)
          .update({'status': 'REFUNDED'})
          .eq('id', bookingId);
    } else {
      // Release payout to group
      await _client
          .from(SupabaseConstants.tablePayouts)
          .update({'status': 'HOLD'})
          .eq('booking_id', bookingId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFailedPayouts() async {
    final data = await _client
        .from(SupabaseConstants.tablePayouts)
        .select('id, booking_id, gross, fee, net, status, retry_count, artist_profiles (display_name, bank_name, bank_no)')
        .eq('status', 'FAILED');

    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> retryPayout(String payoutId) async {
    await _client
        .from(SupabaseConstants.tablePayouts)
        .update({'status': 'HOLD'})
        .eq('id', payoutId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllArtists() async {
    final data = await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .select('id, display_name, category, base_city, status, rating_avg, total_job')
        .order('created_at', ascending: false);

    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> toggleSuspendArtist(String artistId, bool isSuspended) async {
    await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .update({'status': isSuspended ? 'suspended' : 'verified'})
        .eq('id', artistId);
  }
}
