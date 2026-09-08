import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/catalog/data/models/artist_profile_model.dart';
import 'package:mobile/features/catalog/data/models/package_model.dart';
import 'package:mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:mobile/features/catalog/presentation/screens/catalog_search_screen.dart';

const _transparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.value(_transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class MockCatalogRepository implements CatalogRepository {
  final List<ArtistProfileModel> artists;

  MockCatalogRepository(this.artists);

  @override
  Future<List<ArtistProfileModel>> searchArtists({
    String? city,
    String? category,
    int? maxBudget,
    DateTime? availableDate,
  }) async {
    return artists;
  }

  @override
  Future<ArtistProfileModel> getArtistDetail(String artistId) async {
    return artists.firstWhere((a) => a.id == artistId);
  }

  @override
  Future<List<PackageModel>> getPackagesByArtist(String artistId) async {
    return [];
  }

  @override
  Future<List<ZonePriceModel>> getZonePricesByPackage(String packageId) async {
    return [];
  }

  @override
  Future<List<DateTime>> getUnavailableDates(String artistId) async {
    return [];
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  final testArtists = [
    const ArtistProfileModel(
      id: 'a1',
      userId: 'u1',
      displayName: 'Sandiwara Dharma Kudeta',
      category: 'sandiwara-full',
      baseCity: 'Indramayu',
      baseDistrict: 'Kandanghaur',
      coverageCities: ['Indramayu', 'Cirebon', 'Majalengka'],
      ratingAvg: 4.9,
      totalJob: 148,
      priceMin: 9500000,
      priceMax: 15000000,
      autoAccept: true,
    ),
    const ArtistProfileModel(
      id: 'a2',
      userId: 'u2',
      displayName: 'Tarling Dangdut Hj. Dewi Kirana',
      category: 'tarling-dangdut',
      baseCity: 'Indramayu',
      baseDistrict: 'Jatibarang',
      coverageCities: ['Indramayu', 'Cirebon', 'Subang'],
      ratingAvg: 4.9,
      totalJob: 215,
      priceMin: 7000000,
      priceMax: 12000000,
      autoAccept: true,
    ),
    const ArtistProfileModel(
      id: 'a3',
      userId: 'u3',
      displayName: 'Organ Tunggal Rolani Diva',
      category: 'organ-tunggal',
      baseCity: 'Cirebon',
      baseDistrict: 'Arjawinangun',
      coverageCities: ['Cirebon', 'Indramayu'],
      ratingAvg: 4.7,
      totalJob: 89,
      priceMin: 2200000,
      priceMax: 4500000,
      autoAccept: true,
    ),
  ];

  testWidgets('CatalogSearchScreen displays artist cards from repository', (tester) async {
    final mockRepo = MockCatalogRepository(testArtists);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogSearchScreen(repository: mockRepo),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sandiwara Dharma Kudeta'), findsOneWidget);
    expect(find.text('Tarling Dangdut Hj. Dewi Kirana'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Organ Tunggal Rolani Diva'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Organ Tunggal Rolani Diva'), findsOneWidget);
  });

  testWidgets('CatalogSearchScreen filters correctly by query', (tester) async {
    final mockRepo = MockCatalogRepository(testArtists);

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogSearchScreen(repository: mockRepo),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Dewi');
    await tester.pumpAndSettle();

    expect(find.text('Tarling Dangdut Hj. Dewi Kirana'), findsOneWidget);
    expect(find.text('Sandiwara Dharma Kudeta'), findsNothing);
    expect(find.text('Organ Tunggal Rolani Diva'), findsNothing);
  });

  testWidgets('CatalogSearchScreen filters correctly by initialCategory', (tester) async {
    final mockRepo = MockCatalogRepository(testArtists);

    await tester.pumpWidget(
      MaterialApp(
        home: CatalogSearchScreen(
          repository: mockRepo,
          initialCategory: 'sandiwara',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sandiwara Dharma Kudeta'), findsOneWidget);
    expect(find.text('Tarling Dangdut Hj. Dewi Kirana'), findsNothing);
    expect(find.text('Organ Tunggal Rolani Diva'), findsNothing);
  });
}
