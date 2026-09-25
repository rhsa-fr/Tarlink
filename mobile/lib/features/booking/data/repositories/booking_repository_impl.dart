import '../../../../core/network/api_client.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';
import '../models/booking_offer_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl([dynamic _]);

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
    final payload = {
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
    };

    final res = await ApiClient.post('/bookings', body: payload);
    if (res is Map<String, dynamic>) {
      return BookingModel.fromJson(res);
    }
    throw Exception('Gagal membuat pesanan booking');
  }

  @override
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final res = await ApiClient.get('/bookings/$bookingId');
      if (res is Map<String, dynamic>) {
        return BookingModel.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    try {
      final res = await ApiClient.get('/bookings', queryParams: {'customer_id': customerId});
      if (res is List) {
        return res.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> confirmCashPayment({
    required String bookingId,
    required int cashAmount,
    required String receiptPhotoUrl,
  }) async {
    await ApiClient.post('/bookings/$bookingId/cash-confirm', body: {
      'cash_amount': cashAmount,
      'receipt_photo_url': receiptPhotoUrl,
    });
  }

  @override
  Future<List<BookingOfferModel>> getOffers(String bookingId) async {
    try {
      final res = await ApiClient.get('/bookings/$bookingId/offers');
      if (res is List) {
        return res.map((e) => BookingOfferModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
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

    await ApiClient.post('/bookings/$bookingId/offers', body: {
      'offered_by': offeredBy,
      'amount': amount,
      'round': round,
      'note': note,
    });
  }

  @override
  Future<void> acceptOffer({
    required String bookingId,
    required String offerId,
    required int lockedPrice,
  }) async {
    await ApiClient.post('/bookings/$bookingId/offers/$offerId/accept', body: {
      'locked_price': lockedPrice,
    });
  }

  @override
  Future<void> rejectOffer({
    required String bookingId,
    required String offerId,
  }) async {
    await ApiClient.post('/bookings/$bookingId/offers/$offerId/reject');
  }

  @override
  Future<List<BookingMessageModel>> getMessages(String bookingId) async {
    try {
      final res = await ApiClient.get('/bookings/$bookingId/messages');
      if (res is List) {
        return res.map((e) => BookingMessageModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String text,
  }) async {
    await ApiClient.post('/bookings/$bookingId/messages', body: {
      'sender_id': senderId,
      'text': text,
    });
  }
}
