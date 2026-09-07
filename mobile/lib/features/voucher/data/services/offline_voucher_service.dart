import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/evoucher_model.dart';

/// Offline voucher cache service enabling offline E-Voucher access in low-signal rural areas.
class OfflineVoucherService {
  final FlutterSecureStorage _storage;

  OfflineVoucherService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyPrefix = 'voucher_cache_';

  Future<void> saveVoucherOffline(EVoucherModel voucher) async {
    final key = '$_keyPrefix${voucher.code}';
    final jsonStr = jsonEncode(voucher.toJson());
    await _storage.write(key: key, value: jsonStr);
  }

  Future<EVoucherModel?> getOfflineVoucher(String bookingCode) async {
    final key = '$_keyPrefix$bookingCode';
    final jsonStr = await _storage.read(key: key);
    if (jsonStr == null) return null;
    return EVoucherModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  Future<List<EVoucherModel>> getAllOfflineVouchers() async {
    final all = await _storage.readAll();
    final list = <EVoucherModel>[];
    for (final entry in all.entries) {
      if (entry.key.startsWith(_keyPrefix)) {
        try {
          list.add(EVoucherModel.fromJson(jsonDecode(entry.value) as Map<String, dynamic>));
        } catch (_) {}
      }
    }
    return list;
  }
}
