import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/catalog/data/models/artist_profile_model.dart';
import 'package:mobile/features/catalog/data/models/package_model.dart';
import 'package:mobile/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:mobile/features/catalog/presentation/screens/artist_detail_screen.dart';

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

class MockDetailCatalogRepository implements CatalogRepository {
  final List<PackageModel> packages;
  final List<DateTime> unavailableDates;
  final bool shouldThrow;

  MockDetailCatalogRepository({
    this.packages = const [],
    this.unavailableDates = const [],
    this.shouldThrow = false,
  });

  @override
  Future<List<ArtistProfileModel>> searchArtists({
    String? city,
    String? category,
    int? maxBudget,
    DateTime? availableDate,
  }) async => [];

  @override
  Future<ArtistProfileModel> getArtistDetail(String artistId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<PackageModel>> getPackagesByArtist(String artistId) async {
    if (shouldThrow) throw Exception('Network error fetching packages');
    return packages;
  }

  @override
  Future<List<ZonePriceModel>> getZonePricesByPackage(String packageId) async => [];

  @override
  Future<List<DateTime>> getUnavailableDates(String artistId) async {
    if (shouldThrow) throw Exception('Network error fetching dates');
    return unavailableDates;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  const testArtist = ArtistProfileModel(
    id: 'artist-1',
    userId: 'user-1',
    displayName: 'Tarling Dangdut Hj. Dewi Kirana',
    category: 'tarling-dangdut',
    baseCity: 'Indramayu',
    baseDistrict: 'Jatibarang',
    coverageCities: ['Indramayu', 'Cirebon'],
    ratingAvg: 4.9,
    totalJob: 215,
    priceMin: 7000000,
    priceMax: 12000000,
    autoAccept: true,
  );

  test('PackageModel.fromJson handles null and missing price gracefully', () {
    final jsonWithNullPrice = {
      'id': 'pkg-test',
      'artist_id': 'artist-1',
      'name': 'Paket Uji Coba',
      'price': null,
    };
    final pkg = PackageModel.fromJson(jsonWithNullPrice);
    expect(pkg.price, equals(0));
    expect(pkg.name, equals('Paket Uji Coba'));
    expect(pkg.isActive, isTrue);
  });

  testWidgets('ArtistDetailScreen renders artist name and category correctly', (tester) async {
    final mockRepo = MockDetailCatalogRepository();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ArtistDetailScreen(
          artist: testArtist,
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tarling Dangdut Hj. Dewi Kirana'), findsWidgets);
    expect(find.text('Tarling Dangdut Kombinasi'), findsWidgets);
  });

  testWidgets('ArtistDetailScreen loads packages from repository', (tester) async {
    final testPackages = [
      const PackageModel(
        id: 'real-pkg-1',
        artistId: 'artist-1',
        name: 'Paket VVIP Panggung Megah',
        price: 15000000,
        includes: 'Sound 20000W, 4 Sinden',
      ),
    ];

    final mockRepo = MockDetailCatalogRepository(packages: testPackages);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ArtistDetailScreen(
          artist: testArtist,
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paket VVIP Panggung Megah'), findsOneWidget);
  });

  testWidgets('ArtistDetailScreen shows empty state on repository error', (tester) async {
    final mockRepo = MockDetailCatalogRepository(shouldThrow: true);

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ArtistDetailScreen(
          artist: testArtist,
          repository: mockRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Paket di Database'), findsOneWidget);
  });
}
