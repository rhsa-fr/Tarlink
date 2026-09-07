import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../catalog/data/models/artist_profile_model.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseClient _client;

  GroupRepositoryImpl(this._client);

  @override
  Future<ArtistProfileModel?> getMyArtistProfile(String userId) async {
    final data = await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return ArtistProfileModel.fromJson(data);
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
    await _client.from(SupabaseConstants.tableArtistProfiles).insert({
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
      'status': 'pending',
      'auto_accept': false,
    });
  }

  @override
  Future<void> updateAutoAccept(String artistId, bool autoAccept) async {
    await _client
        .from(SupabaseConstants.tableArtistProfiles)
        .update({'auto_accept': autoAccept})
        .eq('id', artistId);
  }

  @override
  Future<void> createPackage({
    required String artistId,
    required String name,
    required int price,
    int? durationHours,
    String? includes,
  }) async {
    await _client.from(SupabaseConstants.tablePackages).insert({
      'artist_id': artistId,
      'name': name,
      'price': price,
      'duration_hours': durationHours,
      'includes': includes,
      'is_active': true,
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
    await _client.from(SupabaseConstants.tablePackages).update({
      'name': name,
      'price': price,
      'duration_hours': durationHours,
      'includes': includes,
    }).eq('id', packageId);
  }

  @override
  Future<void> deletePackage(String packageId) async {
    await _client
        .from(SupabaseConstants.tablePackages)
        .update({'is_active': false})
        .eq('id', packageId);
  }

  @override
  Future<void> setZonePrice({
    required String packageId,
    required String zone,
    required double maxKm,
    required int extraPrice,
  }) async {
    await _client.from(SupabaseConstants.tableZonePrices).upsert(
      {
        'package_id': packageId,
        'zone': zone,
        'max_km': maxKm,
        'extra_price': extraPrice,
      },
      onConflict: 'package_id,zone',
    );
  }

  @override
  Future<List<DateTime>> getBlockedDates(String artistId) async {
    final data = await _client
        .from(SupabaseConstants.tableBlockedDates)
        .select('date')
        .eq('artist_id', artistId);

    final dates = <DateTime>[];
    for (final row in data as List) {
      final parsed = DateTime.tryParse(row['date'] as String);
      if (parsed != null) dates.add(parsed);
    }
    return dates;
  }

  @override
  Future<void> addBlockedDate(String artistId, DateTime date, String? reason) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    await _client.from(SupabaseConstants.tableBlockedDates).upsert(
      {
        'artist_id': artistId,
        'date': dateStr,
        'reason': reason ?? 'Libur mandiri pimpinan',
      },
      onConflict: 'artist_id,date',
    );
  }

  @override
  Future<void> removeBlockedDate(String artistId, DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    await _client
        .from(SupabaseConstants.tableBlockedDates)
        .delete()
        .eq('artist_id', artistId)
        .eq('date', dateStr);
  }

  @override
  Future<Map<String, dynamic>> getPayoutSummary(String artistId) async {
    final data = await _client
        .from(SupabaseConstants.tablePayouts)
        .select('gross, fee, net, status, transferred_at, created_at')
        .eq('artist_id', artistId);

    int totalHold = 0;
    int totalCompleted = 0;
    final history = <Map<String, dynamic>>[];

    for (final row in data as List) {
      final net = row['net'] as int? ?? 0;
      final status = row['status'] as String? ?? 'HOLD';
      if (status == 'HOLD') {
        totalHold += net;
      } else if (status == 'COMPLETED') {
        totalCompleted += net;
      }
      history.add(row as Map<String, dynamic>);
    }

    return {
      'totalHold': totalHold,
      'totalCompleted': totalCompleted,
      'history': history,
    };
  }
}
