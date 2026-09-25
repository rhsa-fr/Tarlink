import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/features/catalog/data/repositories/catalog_repository_impl.dart';

void main() {
  test('CatalogRepository query test with client', () async {
    final mockHttpClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'id': 'a1',
            'slug': 'candra-kirana',
            'display_name': 'Sandiwara Candra Kirana',
            'category': 'sandiwara-full',
            'base_city': 'Indramayu',
            'base_district': 'Kandanghaur',
            'verified_status': 'verified',
            'price_rate': 25000000,
          },
          {
            'id': 'a2',
            'slug': 'diana-sastra',
            'display_name': 'Tarling Dangdut Dian Sastra',
            'category': 'tarling-dangdut',
            'base_city': 'Cirebon',
            'base_district': 'Kedawung',
            'verified_status': 'verified',
            'price_rate': 18000000,
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    ApiClient.setHttpClient(mockHttpClient);
    final repo = CatalogRepositoryImpl();

    final artists = await repo.searchArtists();
    expect(artists.length, equals(2));
    expect(artists.first.displayName, contains('Candra Kirana'));
    expect(artists.last.category, equals('tarling-dangdut'));

    ApiClient.setHttpClient(null);
  });
}


