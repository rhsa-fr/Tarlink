class EVoucherModel {
  final String code; // Misal: TRG-2026-0042
  final String voucherQrData;
  final String artistName;
  final String packageName;
  final String eventDate;
  final String venueAddress;
  final String zone;
  final int totalPrice;
  final int dpPaid;
  final int remainingCash;
  final String customerName;

  const EVoucherModel({
    required this.code,
    required this.voucherQrData,
    required this.artistName,
    required this.packageName,
    required this.eventDate,
    required this.venueAddress,
    required this.zone,
    required this.totalPrice,
    required this.dpPaid,
    required this.remainingCash,
    required this.customerName,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'voucherQrData': voucherQrData,
        'artistName': artistName,
        'packageName': packageName,
        'eventDate': eventDate,
        'venueAddress': venueAddress,
        'zone': zone,
        'totalPrice': totalPrice,
        'dpPaid': dpPaid,
        'remainingCash': remainingCash,
        'customerName': customerName,
      };

  factory EVoucherModel.fromJson(Map<String, dynamic> json) => EVoucherModel(
        code: json['code'] as String,
        voucherQrData: json['voucherQrData'] as String,
        artistName: json['artistName'] as String,
        packageName: json['packageName'] as String,
        eventDate: json['eventDate'] as String,
        venueAddress: json['venueAddress'] as String,
        zone: json['zone'] as String,
        totalPrice: json['totalPrice'] as int,
        dpPaid: json['dpPaid'] as int,
        remainingCash: json['remainingCash'] as int,
        customerName: json['customerName'] as String,
      );
}
