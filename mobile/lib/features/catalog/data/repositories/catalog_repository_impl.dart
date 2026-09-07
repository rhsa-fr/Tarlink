import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../models/artist_profile_model.dart';
import '../models/package_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final SupabaseClient _client;

  CatalogRepositoryImpl(this._client);

  @override
  Future<List<ArtistProfileModel>> searchArtists({
    String? city,
    String? category,
    int? maxBudget,
    DateTime? availableDate,
  }) async {
    var query = _client
        .from(SupabaseConstants.viewArtistPublic)
        .select()
        .eq('status', 'verified');

    if (city != null && city.isNotEmpty) {
      query = query.contains('coverage_cities', [city]);
    }
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }
    if (maxBudget != null) {
      query = query.lte('price_min', maxBudget);
    }

    final data = await query.order('rating_avg', ascending: false);

    return (data as List).map((e) => ArtistProfileModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<ArtistProfileModel> getArtistDetail(String artistId) async {
    final data = await _client
        .from(SupabaseConstants.viewArtistPublic)
        .select()
        .eq('id', artistId)
        .single();

    return ArtistProfileModel.fromJson(data);
  }

  @override
  Future<List<PackageModel>> getPackagesByArtist(String artistId) async {
    final data = await _client
        .from(SupabaseConstants.tablePackages)
        .select()
        .eq('artist_id', artistId)
        .eq('is_active', true)
        .order('price', ascending: true);

    return (data as List).map((e) => PackageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ZonePriceModel>> getZonePricesByPackage(String packageId) async {
    final data = await _client
        .from(SupabaseConstants.tableZonePrices)
        .select()
        .eq('package_id', packageId)
        .order('zone', ascending: true);

    return (data as List).map((e) => ZonePriceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DateTime>> getUnavailableDates(String artistId) async {
    final now = DateTime.now().toUtc().toIso8601String();

    final blockedData = await _client
        .from(SupabaseConstants.tableBlockedDates)
        .select('date')
        .eq('artist_id', artistId)
        .gte('date', now.substring(0, 10));

    final bookedData = await _client
        .from(SupabaseConstants.tableBookings)
        .select('event_date')
        .eq('artist_id', artistId)
        .inFilter('status', ['DP_PAID', 'PARTIAL_PAID', 'FULL_PAID', 'ONGOING'])
        .gte('event_date', now.substring(0, 10));

    final dates = <DateTime>{};

    for (final row in blockedData as List) {
      final d = DateTime.tryParse(row['date'] as String);
      if (d != null) dates.add(d);
    }

    for (final row in bookedData as List) {
      final d = DateTime.tryParse(row['event_date'] as String);
      if (d != null) dates.add(d);
    }

    return dates.toList()..sort();
  }
}
