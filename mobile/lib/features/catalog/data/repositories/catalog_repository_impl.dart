import '../../../../core/network/api_client.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/artist_profile_model.dart';
import '../models/package_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl([dynamic _]);

  @override
  Future<List<ArtistProfileModel>> searchArtists({
    String? city,
    String? category,
    int? maxBudget,
    DateTime? availableDate,
  }) async {
    final queryParams = <String, String>{};
    if (city != null && city.isNotEmpty) queryParams['city'] = city;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;

    final data = await ApiClient.get('/catalog', queryParams: queryParams.isNotEmpty ? queryParams : null);
    if (data is List) {
      var list = data.map((e) => ArtistProfileModel.fromJson(e as Map<String, dynamic>)).toList();
      if (maxBudget != null) {
        list = list.where((a) => a.priceMin <= maxBudget).toList();
      }
      return list;
    }
    return [];
  }

  static final _uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  bool _isValidUuid(String id) => _uuidRegex.hasMatch(id);

  @override
  Future<ArtistProfileModel> getArtistDetail(String artistId) async {
    if (!_isValidUuid(artistId)) {
      throw Exception('Invalid UUID for artistId: $artistId');
    }

    final data = await ApiClient.get('/catalog/$artistId');
    if (data is Map<String, dynamic>) {
      return ArtistProfileModel.fromJson(data);
    }
    throw Exception('Gagal mengambil detail profil grup seni');
  }

  @override
  Future<List<PackageModel>> getPackagesByArtist(String artistId) async {
    if (!_isValidUuid(artistId)) {
      return [];
    }

    final data = await ApiClient.get('/catalog/$artistId');
    if (data is Map<String, dynamic> && data.containsKey('packages')) {
      final pkgList = data['packages'] as List;
      return pkgList.map((e) => PackageModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<List<ZonePriceModel>> getZonePricesByPackage(String packageId) async {
    if (!_isValidUuid(packageId)) {
      return [];
    }
    return [];
  }

  @override
  Future<List<DateTime>> getUnavailableDates(String artistId) async {
    if (!_isValidUuid(artistId)) {
      return [];
    }
    return [];
  }
}
