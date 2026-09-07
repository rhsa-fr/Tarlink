import '../../data/models/artist_profile_model.dart';
import '../../data/models/package_model.dart';

abstract class CatalogRepository {
  Future<List<ArtistProfileModel>> searchArtists({
    String? city,
    String? category,
    int? maxBudget,
    DateTime? availableDate,
  });

  Future<ArtistProfileModel> getArtistDetail(String artistId);

  Future<List<PackageModel>> getPackagesByArtist(String artistId);

  Future<List<ZonePriceModel>> getZonePricesByPackage(String packageId);

  Future<List<DateTime>> getUnavailableDates(String artistId);
}
