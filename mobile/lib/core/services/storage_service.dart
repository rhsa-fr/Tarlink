import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';
import '../network/supabase_client.dart';

/// Service for uploading photos to Supabase Storage buckets.
class StorageService {
  final SupabaseClient _client;

  StorageService([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Uploads cash receipt photo for Hari-H settlement confirmation.
  Future<String> uploadCashReceipt({
    required String bookingCode,
    required Uint8List bytes,
  }) async {
    final fileName = 'receipt_${bookingCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'receipts/$fileName';

    await _client.storage
        .from(SupabaseConstants.bucketCashReceipts)
        .uploadBinary(path, bytes);

    return _client.storage
        .from(SupabaseConstants.bucketCashReceipts)
        .getPublicUrl(path);
  }

  /// Uploads KTP photo for group owner verification.
  Future<String> uploadKtpDocument({
    required String userId,
    required Uint8List bytes,
  }) async {
    final fileName = 'ktp_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'ktp/$fileName';

    await _client.storage
        .from(SupabaseConstants.bucketKtpVerifications)
        .uploadBinary(path, bytes);

    return _client.storage
        .from(SupabaseConstants.bucketKtpVerifications)
        .getPublicUrl(path);
  }

  /// Uploads stage portfolio photo for artist profile.
  Future<String> uploadArtistPhoto({
    required String artistId,
    required Uint8List bytes,
  }) async {
    final fileName = 'stage_${artistId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'photos/$fileName';

    await _client.storage
        .from(SupabaseConstants.bucketArtistPhotos)
        .uploadBinary(path, bytes);

    return _client.storage
        .from(SupabaseConstants.bucketArtistPhotos)
        .getPublicUrl(path);
  }
}
