import '../../../catalog/data/models/artist_profile_model.dart';

abstract class GroupRepository {
  Future<ArtistProfileModel?> getMyArtistProfile(String userId);

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
  });

  Future<void> updateAutoAccept(String artistId, bool autoAccept);

  Future<void> createPackage({
    required String artistId,
    required String name,
    required int price,
    int? durationHours,
    String? includes,
  });

  Future<void> updatePackage({
    required String packageId,
    required String name,
    required int price,
    int? durationHours,
    String? includes,
  });

  Future<void> deletePackage(String packageId);

  Future<void> setZonePrice({
    required String packageId,
    required String zone,
    required double maxKm,
    required int extraPrice,
  });

  Future<List<DateTime>> getBlockedDates(String artistId);

  Future<void> addBlockedDate(String artistId, DateTime date, String? reason);

  Future<void> removeBlockedDate(String artistId, DateTime date);

  Future<Map<String, dynamic>> getPayoutSummary(String artistId);
}
