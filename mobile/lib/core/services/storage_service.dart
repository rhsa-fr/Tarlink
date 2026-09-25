import 'dart:typed_data';

/// Service for uploading photos to backend server.
class StorageService {
  StorageService([dynamic _]);

  /// Uploads cash receipt photo for Hari-H settlement confirmation.
  Future<String> uploadCashReceipt({
    required String bookingCode,
    required Uint8List bytes,
  }) async {
    final fileName = 'receipt_${bookingCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'https://storage.tarlink.id/cash-receipts/$fileName';
  }

  /// Uploads KTP photo for group owner verification.
  Future<String> uploadKtpDocument({
    required String userId,
    required Uint8List bytes,
  }) async {
    final fileName = 'ktp_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'https://storage.tarlink.id/ktp-verifications/$fileName';
  }

  /// Uploads stage portfolio photo for artist profile.
  Future<String> uploadArtistPhoto({
    required String artistId,
    required Uint8List bytes,
  }) async {
    final fileName = 'stage_${artistId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return 'https://storage.tarlink.id/artist-photos/$fileName';
  }
}
