import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import '../models/booking_offer_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final SupabaseClient _client;

  BookingRepositoryImpl(this._client);

  @override
  Future<BookingModel> createBooking({
    required String customerId,
    required String artistId,
    required String packageId,
    required String eventDate,
    required String venueAddress,
    String? venueMapsUrl,
    required String city,
    required String district,
    required double venueLat,
    required double venueLng,
    String bookingType = 'instant',
    String? note,
  }) async {
    // CRITICAL: Financial calculation & validation strictly executed by Supabase Edge Function!
    final response = await _client.functions.invoke(
      SupabaseConstants.fnCreateBooking,
      body: {
        'customer_id': customerId,
        'artist_id': artistId,
        'package_id': packageId,
        'event_date': eventDate,
        'venue_address': venueAddress,
        'venue_maps_url': venueMapsUrl,
        'city': city,
        'district': district,
        'venue_lat': venueLat,
        'venue_lng': venueLng,
        'booking_type': bookingType,
        'note': note,
      },
    );

    if (response.status != 201 && response.status != 200) {
      final data = response.data as Map<String, dynamic>?;
      throw Exception(data?['message'] ?? 'Gagal membuat pesanan booking');
    }

    final bookingJson = (response.data as Map<String, dynamic>)['booking'];
    return BookingModel.fromJson(bookingJson as Map<String, dynamic>);
  }

  @override
  Future<BookingModel?> getBookingById(String bookingId) async {
    final data = await _client
        .from(SupabaseConstants.tableBookings)
        .select()
        .eq('id', bookingId)
        .maybeSingle();

    if (data == null) return null;
    return BookingModel.fromJson(data);
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    final data = await _client
        .from(SupabaseConstants.tableBookings)
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> confirmCashPayment({
    required String bookingId,
    required int cashAmount,
    required String receiptPhotoUrl,
  }) async {
    await _client.from(SupabaseConstants.tableBookings).update({
      'cash_received': cashAmount,
      'cash_proof_url': receiptPhotoUrl,
      'cash_confirmed': true,
      'status': 'COMPLETED',
      'completed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', bookingId);
  }
  @override
  Future<List<BookingOfferModel>> getOffers(String bookingId) async {
    final data = await _client
        .from(SupabaseConstants.tableBookingOffers)
        .select()
        .eq('booking_id', bookingId)
        .order('round', ascending: true);

    return (data as List).map((e) => BookingOfferModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitOffer({
    required String bookingId,
    required String offeredBy,
    required int amount,
    required int round,
    String? note,
  }) async {
    if (round > 3) {
      throw Exception('Maksimal tawar-menawar adalah 3 ronde');
    }

    final expiresAt = DateTime.now().add(const Duration(hours: 12)).toUtc().toIso8601String();

    await _client.from(SupabaseConstants.tableBookingOffers).insert({
      'booking_id': bookingId,
      'offered_by': offeredBy,
      'amount': amount,
      'round': round,
      'note': note,
      'status': 'proposed',
      'expires_at': expiresAt,
    });
  }

  @override
  Future<void> acceptOffer({
    required String bookingId,
    required String offerId,
    required int lockedPrice,
  }) async {
    // 1. Mark offer accepted
    await _client
        .from(SupabaseConstants.tableBookingOffers)
        .update({'status': 'accepted'})
        .eq('id', offerId);

    // 2. Lock price and transition booking to WAITING_DP
    final dpAmount = (lockedPrice * 0.20).round();
    final remainingAmount = lockedPrice - dpAmount;

    await _client.from(SupabaseConstants.tableBookings).update({
      'final_price': lockedPrice,
      'total_price': lockedPrice,
      'dp_amount': dpAmount,
      'remaining_amount': remainingAmount,
      'locked_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'WAITING_DP',
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toUtc().toIso8601String(),
    }).eq('id', bookingId);
  }

  @override
  Future<void> rejectOffer({
    required String bookingId,
    required String offerId,
  }) async {
    await _client
        .from(SupabaseConstants.tableBookingOffers)
        .update({'status': 'rejected'})
        .eq('id', offerId);

    await _client
        .from(SupabaseConstants.tableBookings)
        .update({'status': 'CANCELLED', 'cancel_reason': 'Tawaran harga ditolak'})
        .eq('id', bookingId);
  }

  @override
  Future<List<BookingMessageModel>> getMessages(String bookingId) async {
    final data = await _client
        .from(SupabaseConstants.tableMessages)
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => BookingMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String text,
  }) async {
    await _client.from(SupabaseConstants.tableMessages).insert({
      'booking_id': bookingId,
      'sender_id': senderId,
      'text': text,
    });
  }
}
