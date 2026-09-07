class BookingOfferModel {
  final String id;
  final String bookingId;
  final String offeredBy;
  final int amount; // Rupiah integer
  final String? note;
  final int round; // Max 3 rounds
  final String status; // 'proposed', 'accepted', 'rejected', 'expired'
  final DateTime? expiresAt;
  final DateTime createdAt;

  const BookingOfferModel({
    required this.id,
    required this.bookingId,
    required this.offeredBy,
    required this.amount,
    this.note,
    required this.round,
    this.status = 'proposed',
    this.expiresAt,
    required this.createdAt,
  });

  bool get isProposed => status == 'proposed';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired';

  factory BookingOfferModel.fromJson(Map<String, dynamic> json) {
    return BookingOfferModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      offeredBy: json['offered_by'] as String,
      amount: json['amount'] as int,
      note: json['note'] as String?,
      round: json['round'] as int,
      status: json['status'] as String? ?? 'proposed',
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'offered_by': offeredBy,
        'amount': amount,
        'note': note,
        'round': round,
        'status': status,
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

class BookingMessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String text;
  final String? attachmentUrl;
  final DateTime createdAt;

  const BookingMessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.text,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory BookingMessageModel.fromJson(Map<String, dynamic> json) {
    return BookingMessageModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
    );
  }
}
