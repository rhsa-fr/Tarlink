class BookingModel {
  final String id;
  final String code;
  final String customerId;
  final String artistId;
  final String packageId;
  final DateTime eventDate;
  final String venueAddress;
  final String? venueMapsUrl;
  final String city;
  final String district;
  final double? venueLat;
  final double? venueLng;
  final double? distanceKm;
  final String? zone;
  final int totalPrice;
  final int dpPercent;
  final int dpAmount;
  final int remainingAmount;
  final String bookingType; // 'instant' | 'custom'
  final String? evoucherCode;
  final String status;
  final int cashReceived;
  final bool cashConfirmed;
  final DateTime? paidDpAt;
  final DateTime? completedAt;
  final String? artistName;
  final String? packageName;
  final String? artistAvatarUrl;

  const BookingModel({
    required this.id,
    required this.code,
    required this.customerId,
    required this.artistId,
    required this.packageId,
    required this.eventDate,
    required this.venueAddress,
    this.venueMapsUrl,
    required this.city,
    required this.district,
    this.venueLat,
    this.venueLng,
    this.distanceKm,
    this.zone,
    required this.totalPrice,
    this.dpPercent = 20,
    required this.dpAmount,
    required this.remainingAmount,
    this.bookingType = 'instant',
    this.evoucherCode,
    this.status = 'PENDING',
    this.cashReceived = 0,
    this.cashConfirmed = false,
    this.paidDpAt,
    this.completedAt,
    this.artistName,
    this.packageName,
    this.artistAvatarUrl,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      code: json['code'] as String,
      customerId: json['customer_id'] as String,
      artistId: json['artist_id'] as String,
      packageId: json['package_id'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      venueAddress: json['venue_address'] as String,
      venueMapsUrl: json['venue_maps_url'] as String?,
      city: json['city'] as String,
      district: json['district'] as String,
      venueLat: json['venue_lat'] != null ? (json['venue_lat'] as num).toDouble() : null,
      venueLng: json['venue_lng'] != null ? (json['venue_lng'] as num).toDouble() : null,
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      zone: json['zone'] as String?,
      totalPrice: json['total_price'] as int,
      dpPercent: json['dp_percent'] as int? ?? 20,
      dpAmount: json['dp_amount'] as int,
      remainingAmount: json['remaining_amount'] as int,
      bookingType: json['booking_type'] as String? ?? 'instant',
      evoucherCode: json['evoucher_code'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      cashReceived: json['cash_received'] as int? ?? 0,
      cashConfirmed: json['cash_confirmed'] as bool? ?? false,
      paidDpAt: json['paid_dp_at'] != null ? DateTime.tryParse(json['paid_dp_at'] as String) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      artistName: json['artist_name'] as String?,
      packageName: json['package_name'] as String?,
      artistAvatarUrl: json['artist_avatar_url'] as String?,
    );
  }
}
