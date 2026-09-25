import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/data/models/artist_profile_model.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl([dynamic _]);

  @override
  Future<ArtistProfileModel?> getMyArtistProfile(String userId) async {
    try {
      final res = await ApiClient.get('/catalog');
      if (res is List && res.isNotEmpty) {
        return ArtistProfileModel.fromJson(res.first as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> registerStall({
    required String userId,
    required String displayName,
    required String category,
    required String baseCity,
    required String baseDistrict,
    required String description,
    required String bankName,
    required String bankNo,
    required String bankOwner,
    String? ktpUrl,
  }) async {
    await ApiClient.post('/artist/stall', body: {
      'user_id': userId,
      'display_name': displayName,
      'category': category,
      'base_city': baseCity,
      'base_district': baseDistrict,
      'description': description,
      'bank_name': bankName,
      'bank_no': bankNo,
      'bank_owner': bankOwner,
      'ktp_url': ktpUrl,
    });
  }

  @override
  Future<void> updateAutoAccept(String artistId, bool autoAccept) async {
    await ApiClient.post('/artist/auto-accept', body: {
      'artist_id': artistId,
      'auto_accept': autoAccept,
    });
  }

  @override
  Future<void> createPackage({
    required String artistId,
    required String name,
    required int price,
    int? durationHours,
    String? includes,
  }) async {
    await ApiClient.post('/artist/packages', body: {
      'artist_id': artistId,
      'name': name,
      'price': price,
      'duration_hours': durationHours,
      'includes': includes,
    });
  }

  @override
  Future<void> updatePackage({
    required String packageId,
    required String name,
    required int price,
    int? durationHours,
    String? includes,
  }) async {
    await ApiClient.post('/artist/packages/$packageId', body: {
      'name': name,
      'price': price,
      'duration_hours': durationHours,
      'includes': includes,
    });
  }

  @override
  Future<void> deletePackage(String packageId) async {
    await ApiClient.post('/artist/packages/$packageId/delete');
  }

  @override
  Future<void> setZonePrice({
    required String packageId,
    required String zone,
    required double maxKm,
    required int extraPrice,
  }) async {
    await ApiClient.post('/artist/zones', body: {
      'package_id': packageId,
      'zone': zone,
      'max_km': maxKm,
      'extra_price': extraPrice,
    });
  }

  @override
  Future<List<DateTime>> getBlockedDates(String artistId) async {
    return [];
  }

  @override
  Future<void> addBlockedDate(String artistId, DateTime date, String? reason) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    await ApiClient.post('/artist/blocked-dates', body: {
      'artist_id': artistId,
      'date': dateStr,
      'reason': reason,
    });
  }

  @override
  Future<void> removeBlockedDate(String artistId, DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    await ApiClient.post('/artist/blocked-dates/remove', body: {
      'artist_id': artistId,
      'date': dateStr,
    });
  }

  @override
  Future<Map<String, dynamic>> getPayoutSummary(String artistId) async {
    try {
      final res = await ApiClient.get('/admin/payouts');
      if (res is List) {
        int totalHold = 0;
        int totalCompleted = 0;
        for (final row in res) {
          final net = row['net'] as int? ?? 0;
          final status = row['status'] as String? ?? 'HOLD';
          if (status == 'HOLD') totalHold += net;
          if (status == 'COMPLETED') totalCompleted += net;
        }
        return {
          'totalHold': totalHold,
          'totalCompleted': totalCompleted,
          'history': res,
        };
      }
    } catch (_) {}
    return {
      'totalHold': 0,
      'totalCompleted': 0,
      'history': [],
    };
  }
}
