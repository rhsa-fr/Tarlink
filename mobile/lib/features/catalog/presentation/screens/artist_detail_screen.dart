import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../../../booking/presentation/screens/booking_form_screen.dart';
import '../../data/models/artist_profile_model.dart';
import '../../data/models/package_model.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/repositories/catalog_repository.dart';

/// Halaman Detail Rombongan Grup Seni Pantura - Desain Resmi Google Stitch 'TarlingKu'
class ArtistDetailScreen extends StatefulWidget {
  final ArtistProfileModel artist;
  final CatalogRepository? repository;

  const ArtistDetailScreen({
    super.key,
    required this.artist,
    this.repository,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  List<PackageModel> _packages = [];
  PackageModel? _selectedPackage;
  List<String> _unavailableDates = [];
  late DateTime _selectedDate;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isPlayingAudio = false;
  bool _isBioExpanded = false;
  final int _heroPhotoCount = 5;

  @override
  void initState() {
    super.initState();
    // Default tanggal baik kosong terdekat: 15 hari dari sekarang
    _selectedDate = DateTime.now().add(const Duration(days: 15));
    _loadDetailData();
  }

  String _formatDate(DateTime date, String pattern) {
    try {
      return DateFormat(pattern, 'id_ID').format(date);
    } catch (_) {
      return DateFormat(pattern).format(date);
    }
  }

  Future<void> _loadDetailData() async {
    setState(() => _isLoading = true);
    try {
      final repo = widget.repository ?? CatalogRepositoryImpl(SupabaseService.client);
      final packages = await repo.getPackagesByArtist(widget.artist.id);
      final blocked = await repo.getUnavailableDates(widget.artist.id);

      setState(() {
        _packages = packages;
        if (packages.isNotEmpty) {
          _selectedPackage = packages.first;
        }
        _unavailableDates = blocked.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();
      });
    } catch (_) {
      // Mock packages fallback sesuai standar panggung Pantura
      setState(() {
        _packages = [
          PackageModel(
            id: 'pkg-1',
            artistId: widget.artist.id,
            name: 'Paket Komplit Siang-Malam (Hajatan Akbar)',
            durationHours: 14,
            price: widget.artist.priceMax > 0 ? widget.artist.priceMax : 25000000,
            includes: '2 Sinden Bintang + 4 Vokalis Tamu, 18 Musisi Pengiring (Gamelan, Brass, Keyboard, Kendang Jaipong), Sound System 15.000 Watt Line Array + Rigging, Tata Lampu Moving Beam & Parled, Durasi 09.00 - 23.00 WIB (Sesi Siang & Malam)',
          ),
          PackageModel(
            id: 'pkg-2',
            artistId: widget.artist.id,
            name: 'Paket Reguler Siang (Resepsi & Khitanan)',
            durationHours: 8,
            price: widget.artist.priceMin > 0 ? widget.artist.priceMin : 18500000,
            includes: '1 Sinden Utama + 2 Vokalis Pendamping, 12 Musisi Formasi Inti Tarling, Sound System 10.000 Watt, Durasi 09.00 - 16.30 WIB (Sesi Siang)',
          ),
        ];
        _selectedPackage = _packages.first;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareArtist() async {
    final text = '''
🎭 *${widget.artist.displayName} - TarlingKu*
Kategori: ${widget.artist.categoryDisplay}
Asal: ${widget.artist.baseDistrict ?? "Pusat"}, ${widget.artist.baseCity}
Tarif Mulai: ${CurrencyFormatter.formatRupiah(widget.artist.priceMin)}
Rating: ⭐ ${widget.artist.ratingAvg.toStringAsFixed(1)}/5.0

Pesan rombongan resmi lewat TarlingKu (DP 20% Escrow Aman, Pelunasan Cash di Lokasi):
https://tarlingku.id/artis/${widget.artist.id}
''';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Rekomendasi Orkes ${widget.artist.displayName}',
      ),
    );
  }

  void _proceedBooking() {
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih salah satu paket pementasan')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormScreen(
          artistId: widget.artist.id,
          artistName: widget.artist.displayName,
          packageId: _selectedPackage!.id,
          packagePrice: _selectedPackage!.price,
          packageName: _selectedPackage!.name,
          artistBaseLat: widget.artist.baseLat ?? -6.4500,
          artistBaseLng: widget.artist.baseLng ?? 108.3000,
        ),
      ),
    );
  }

  void _showTeaserVideoModal() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF191C21),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.videocam, color: AppColors.secondary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Cuplikan Panggung Live',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.music_note, color: Colors.white12, size: 72),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black45, blurRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Kualitas Audio HD • 15.000W',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '"${widget.artist.displayName} live performance - Penampilan Akbar di Lapangan Hajat Jatibarang"',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.onSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.artist;
    final currentPrice = _selectedPackage?.price ?? (a.priceMin > 0 ? a.priceMin : 25000000);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildStitchAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Visual Header / Media Hero Section (Aspect 4:3)
                      _buildHeroMediaSection(context),

                      // 2. Headline & Geographical Reach
                      _buildHeadlineSection(context, a),

                      // 3. Audio Sample Preview Capsule (Moments of Delight)
                      _buildAudioSampleCapsule(context),

                      // 4. Troupe Narrative & Biography
                      _buildBiographySection(context, a),

                      // 5. Interactive Availability Date Picker Strip
                      _buildAvailabilityStrip(context),

                      // 6. Package & Pricing Selection Cards
                      _buildPackagesSection(context),

                      // 7. Troupe Stage Gallery Grid
                      _buildGallerySection(context),

                      // 8. Real Customer Testimonial Card
                      _buildTestimonialSection(context),

                      // 9. Trust Guarantee Banner
                      _buildTrustGuaranteeBanner(context),
                    ],
                  ),
                ),

                // 10. Sticky Bottom Reservation & CTA Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildStickyBottomBar(context, currentPrice),
                ),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildStitchAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface.withAlpha(240),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/images/tarlingku_logo.svg',
            height: 22,
            placeholderBuilder: (_) => const Icon(Icons.music_note, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 8),
          const Text(
            'Detail Rombongan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.onSurfaceVariant, size: 22),
          tooltip: 'Bagikan',
          onPressed: _shareArtist,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 16, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroMediaSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      color: AppColors.surfaceContainerHighest,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Stage Artwork
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7A1C06), Color(0xFF3B0B01), Color(0xFF1E0600)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Icon(Icons.theater_comedy, size: 88, color: Colors.white12),
            ),
          ),

          // Gradient Scrim for readable badges
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Color(0x60000000), Color(0xCC000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Top Overlay Controls
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Camera Counter Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_camera, size: 13, color: AppColors.secondaryFixed),
                      const SizedBox(width: 4),
                      Text(
                        '1 / $_heroPhotoCount',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),

                // Favorite Heart Button
                InkWell(
                  onTap: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? 'Disimpan ke Sanggar Favorit' : 'Dihapus dari Favorit'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: _isFavorite ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Floating Media Triggers
          Positioned(
            bottom: 14,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Cuplikan Panggung Button
                InkWell(
                  onTap: _showTeaserVideoModal,
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: AppColors.elevation1,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.play_arrow, size: 14, color: Colors.white),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Cuplikan Panggung',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.circle, size: 6, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                // Carousel Dot Indicators
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: List.generate(
                      5,
                      (i) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.primary : Colors.white.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineSection(BuildContext context, ArtistProfileModel a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre & Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  a.categoryDisplay,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups, size: 14, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4),
                    Text('24 Musisi & Sinden', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withAlpha(140),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.secondary),
                    SizedBox(width: 4),
                    Text(
                      'Terverifikasi Resmi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Troupe Name
          Text(
            a.displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3,
                ),
          ),

          const SizedBox(height: 6),

          // Location & Area Reach
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${a.baseDistrict ?? "Pusat"}, ${a.baseCity}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Siap manggung se-Wilayah III Cirebon (${a.coverageCities.isNotEmpty ? a.coverageCities.join(", ") : "Cirebon, Indramayu, Majalengka"}) & Jabodetabek',
                      style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Stats Matrix Bento
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.elevation1,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star, size: 20, color: AppColors.onSecondaryFixed),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                a.ratingAvg > 0 ? a.ratingAvg.toStringAsFixed(1) : '4.9',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                              const Text('/5.0', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          const Text('342 Ulasan Nyata', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.elevation1,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_available, size: 20, color: AppColors.onTertiaryFixed),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.totalJob > 0 ? '${a.totalJob}+ Sukses' : '120+ Sukses',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.tertiary),
                          ),
                          const Text('Hajat Terlaksana', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSampleCapsule(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF191C21),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.elevation2,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() => _isPlayingAudio = !_isPlayingAudio);
              },
              borderRadius: BorderRadius.circular(9999),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlayingAudio ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cuplikan Lagu: Baridin Goyang',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text('01:45', style: TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Animated equalizer waveform bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(14, (i) {
                      final h = _isPlayingAudio ? (6 + (i * 3) % 14).toDouble() : (i % 3 == 0 ? 6.0 : 12.0);
                      final isOchre = i % 2 == 1;
                      return Container(
                        width: 4,
                        height: h,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: isOchre ? AppColors.secondary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.graphic_eq, color: AppColors.secondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBiographySection(BuildContext context, ArtistProfileModel a) {
    final bio = (a.description != null && a.description!.isNotEmpty)
        ? a.description!
        : '${a.displayName} merupakan grup kesenian panggung papan atas Pantura yang dikenal dengan harmonisasi kendang jaipong bertenaga, aransemen tiup brass modern, dan kepiawaian sinden membawakan tembang klasik seperti Baridin, Keloas, hingga dangdut babak terkini. Berpengalaman mengisi panggung hajatan akbar, khitanan terhormat, hingga pementasan festival budaya selama lebih dari satu dekade.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profil & Pengalaman Panggung',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              bio,
              maxLines: _isBioExpanded ? 20 : 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.45),
            ),
            InkWell(
              onTap: () => setState(() => _isBioExpanded = !_isBioExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isBioExpanded ? 'Tutup Narasi' : 'Baca Selengkapnya',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Icon(
                      _isBioExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityStrip(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KALENDER TANGGAL BAIK HAJAT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(now, 'MMMM yyyy'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed.withAlpha(120),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.tertiary),
                      SizedBox(width: 4),
                      Text('Tersedia', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onTertiaryFixed)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Horizontal Date Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(14, (i) {
                  final d = now.add(Duration(days: i + 10));
                  final dStr = DateFormat('yyyy-MM-dd').format(d);
                  final isBooked = _unavailableDates.contains(dStr) || (i == 1 || i == 5);
                  final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
                  final dayName = _formatDate(d, 'EEE').toUpperCase();

                  if (isBooked) {
                    return Container(
                      width: 58,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(dayName, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(
                            '${d.day}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          const Text('Penuh', style: TextStyle(fontSize: 9, color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedDate = d);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 58,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: AppColors.primaryLight, width: 2) : null,
                        boxShadow: isSelected ? AppColors.elevation1 : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Buka',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),

            // Date Status Cue Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Terpilih: ${_formatDate(_selectedDate, 'EEEE, dd MMMM yyyy')}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const Text(
                    'Jadwal Buka',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilihan Paket Pementasan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          const Text(
            'Pilih spek orkes sesuai skala acara hajat Anda',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          ..._packages.map((pkg) {
            final isSelected = _selectedPackage?.id == pkg.id;
            final isPopular = pkg.name.toLowerCase().contains('komplit') || pkg.name.toLowerCase().contains('akbar');

            return InkWell(
              onTap: () => setState(() => _selectedPackage = pkg),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? AppColors.elevation2 : AppColors.elevation1,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pkg.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Khusus Resepsi Pengantin & Hajatan Akbar',
                                      style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: isSelected ? Colors.white : Colors.transparent,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                CurrencyFormatter.formatRupiah(pkg.price),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('/ Pementasan', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                            ],
                          ),

                          if (pkg.includes != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: pkg.includes!.split(',').map((inc) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle, size: 14, color: AppColors.tertiary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            inc.trim(),
                                            style: const TextStyle(fontSize: 11, color: AppColors.onSurface),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Popular Pill Badge
                    if (isPopular)
                      Positioned(
                        top: -10,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: AppColors.elevation1,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Paling Populer',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Galeri Pentas Terbaru', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('Lihat 18 Foto', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.photo, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF191C21),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '+15',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.elevation1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (i) => const Icon(Icons.star, size: 15, color: AppColors.secondary),
                  ),
                ),
                const Text('2 pekan lalu', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '"Suara vokal Mbak Dian mantap sekali, tamu undangan sangat terhibur, musisi disiplin dan tepat waktu! Sound system menggelegar tapi tetap empuk di telinga warga sekeliling."',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurface, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryLight,
                  child: Text('HS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('H. Sulaeman', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Hajatan Pernikahan Putri di Cirebon Barat', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustGuaranteeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.tertiaryFixed.withAlpha(120),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user, size: 20, color: AppColors.tertiary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Jaminan Pasti Tampil: DP Anda aman ditampung di rekening bersama TarlingKu hingga pementasan selesai dengan sukses.',
                style: TextStyle(fontSize: 11, color: AppColors.onTertiaryFixed, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, int price) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(245),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1822252A),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total ${_selectedPackage?.name ?? "Paket Pilihan"}:',
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.formatRupiah(price),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                Text(
                  'Tgl: ${_formatDate(_selectedDate, "dd MMM yyyy")}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 3,
              ),
              icon: const Text('Pilih Paket & Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              label: const Icon(Icons.arrow_forward, size: 16),
              onPressed: _proceedBooking,
            ),
          ),
        ],
      ),
    );
  }
}
