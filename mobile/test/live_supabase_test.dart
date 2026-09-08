// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/core/constants/supabase_constants.dart';
import 'package:mobile/features/catalog/data/repositories/catalog_repository_impl.dart';

void main() {
  test('Live Supabase query test for searchArtists', () async {
    final client = SupabaseClient(
      SupabaseConstants.defaultUrl,
      SupabaseConstants.defaultAnonKey,
    );

    final repo = CatalogRepositoryImpl(client);

    print('Testing searchArtists with no filters...');
    final allArtists = await repo.searchArtists();
    print('All artists count: ${allArtists.length}');
    for (final a in allArtists) {
      print('Artist: ${a.displayName}, category: ${a.category}, city: ${a.baseCity}');
    }

    print('\nTesting searchArtists with city: Indramayu...');
    try {
      final indramayuArtists = await repo.searchArtists(city: 'Indramayu');
      print('Indramayu artists count: ${indramayuArtists.length}');
    } catch (e, stack) {
      print('ERROR on city filter: $e\n$stack');
    }

    print('\nTesting searchArtists with category: tarling-dangdut...');
    try {
      final catArtists = await repo.searchArtists(category: 'tarling-dangdut');
      print('Cat artists count: ${catArtists.length}');
    } catch (e, stack) {
      print('ERROR on category filter: $e\n$stack');
    }
  });
}
