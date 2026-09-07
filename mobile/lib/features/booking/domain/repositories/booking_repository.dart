import '../../data/models/booking_model.dart';
import '../../data/models/booking_offer_model.dart';

abstract class BookingRepository {
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
  });

  Future<BookingModel?> getBookingById(String bookingId);

  Future<List<BookingModel>> getCustomerBookings(String customerId);

  Future<void> confirmCashPayment({
    required String bookingId,
    required int cashAmount,
    required String receiptPhotoUrl,
  });

  Future<List<BookingOfferModel>> getOffers(String bookingId);

  Future<void> submitOffer({
    required String bookingId,
    required String offeredBy,
    required int amount,
    required int round,
    String? note,
  });

  Future<void> acceptOffer({
    required String bookingId,
    required String offerId,
    required int lockedPrice,
  });

  Future<void> rejectOffer({
    required String bookingId,
    required String offerId,
  });

  Future<List<BookingMessageModel>> getMessages(String bookingId);

  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String text,
  });
}
