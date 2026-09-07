import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/tarlink_logo.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/artist_profile_model.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'artist_detail_screen.dart';
import 'catalog_search_screen.dart';
import 'favorites_screen.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../../../chat_bot/presentation/screens/faq_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

/// Beranda Utama Tarlink - Mengacu pada Desain Google Stitch 'Tarlink Booking App UI'
class HomeScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;
  final CatalogRepository? repository;

  const HomeScreen({super.key, this.onExploreTap, this.repository});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<ArtistProfileModel> _artists = [];
  bool _isPlayingAudio = false;
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    setState(() => _isLoading = true);
    try {
      final repo = widget.repository ?? CatalogRepositoryImpl(SupabaseService.client);
      final results = await repo.searchArtists();
      if (mounted) {
        setState(() {
          _artists = results;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _artists = _mockArtists();
          _isLoading = false;
        });
      }
    }
  }

  List<ArtistProfileModel> _mockArtists() {
    return const [
      ArtistProfileModel(
        id: 'mock-1',
        userId: 'u-1',
        displayName: 'Dian Anic & Anica Nada',
        category: 'Tarling Dangdut Modern',
        baseCity: 'Indramayu',
        baseDistrict: 'Jatibarang',
        priceMin: 18500000,
        ratingAvg: 4.9,
        totalJob: 340,
      ),
      ArtistProfileModel(
        id: 'mock-2',
        userId: 'u-2',
        displayName: 'Susi Arzety - Nada Cantika',
        category: 'Tarling Dangdut Kombinasi',
        baseCity: 'Cirebon',
        baseDistrict: 'Kedawung',
        priceMin: 15000000,
        ratingAvg: 4.8,
        totalJob: 215,
      ),
      ArtistProfileModel(
        id: 'mock-3',
        userId: 'u-3',
        displayName: 'Wa Kancil Klasik Tarling',
        category: 'Tarling Klasik Asli',
        baseCity: 'Indramayu',
        baseDistrict: 'Karangampel',
        priceMin: 12000000,
        ratingAvg: 4.9,
        totalJob: 180,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildStitchAppBar(context),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadArtists,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar Pill with Filter Button
              _buildSearchBar(context),

              // 2. Festive Announcement Pill
              _buildFestiveBanner(context),

              // 3. Promo Musim Hajatan 2025 Carousel Banner
              _buildPromoBanner(context),

              // 4. Kategori Acara (4-Grid)
              _buildEventCategories(context),

              // 5. Grup Tarling Populer (Horizontal Carousel)
              _buildPopularTroupes(context),

              // 6. Live Audio Sample Strip (Moments of Delight)
              _buildAudioSampleStrip(context),

              // 7. Panduan & Kalender Hajat (Trust Indicators)
              _buildHajatGuide(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildStitchAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: const TarlinkLogo(height: 30, showSubtitle: true),
      actions: [
        // Location Badge Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 15, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Pantura',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),

        // Wishlist / Favorit
        IconButton(
          icon: const Icon(Icons.bookmark_outline, color: AppColors.textPrimary, size: 22),
          tooltip: 'Sanggar Tersimpan',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
        ),

        // Notification Bell with unread dot
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
        ),

        // Profile Avatar Button
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              );
            },
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 1.5),
              ),
              child: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 18, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: InkWell(
        onTap: () {
          if (widget.onExploreTap != null) {
            widget.onExploreTap!();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatalogSearchScreen()),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.elevationLevel1,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.search, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cari grup tarling, sandiwara, orkes...',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFestiveBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.secondaryDark, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Musim Panen & Hajat Ramai di Cirebon-Indramayu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSecondaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () {
                _showCalendarAdviceModal(context);
              },
              child: Text(
                'Cek Tanggal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFBD4024), Color(0xFF9B280E), Color(0xFF3D0600)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppColors.elevationLevel2,
        ),
        child: Stack(
          children: [
            // Megamendung Motif Accents
            const Positioned(
              right: -20,
              bottom: -20,
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(Icons.cloud_queue, size: 180, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_fire_department, color: AppColors.onSecondaryContainer, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'TERBATAS MUSIM INI',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSecondaryContainer,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'KODE: HAJAT2026',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Promo Musim Hajatan Pantura',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Booking paket tarling lengkap, dapatkan gratis sound system tambahan 5.000 Watt khusus wilayah Cirebon & Indramayu!',
                    style: GoogleFonts.plusJakartaSans(
                      color: Color(0xFFFFDAD2),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voucher HAJAT2026 berhasil disalin! Potongan aktif saat checkout.'),
                          backgroundColor: AppColors.primaryDark,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      minimumSize: const Size(140, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Klaim Kupon', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCategories(BuildContext context) {
    final categories = [
      {
        'title': 'Pernikahan',
        'sub': 'Resepsi',
        'icon': Icons.favorite,
        'color': AppColors.primary,
        'bg': AppColors.primaryLight,
        'slug': 'sandiwara',
      },
      {
        'title': 'Khitanan',
        'sub': 'Sunatan',
        'icon': Icons.child_friendly,
        'color': AppColors.secondaryDark,
        'bg': AppColors.secondaryLight,
        'slug': 'tarling_dangdut',
      },
      {
        'title': 'Syukuran',
        'sub': 'Milad/Hajat',
        'icon': Icons.cake,
        'color': AppColors.tertiary,
        'bg': AppColors.tertiaryContainer.withValues(alpha: 0.25),
        'slug': 'organ_tunggal',
      },
      {
        'title': 'Panggung',
        'sub': 'Bumi/Desa',
        'icon': Icons.speaker_group,
        'color': const Color(0xFF22252A),
        'bg': AppColors.surfaceContainerHigh,
        'slug': 'wayang_kulit',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Kategori Acara',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  if (widget.onExploreTap != null) {
                    widget.onExploreTap!();
                  }
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((c) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CatalogSearchScreen(initialCategory: c['slug'] as String),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: c['bg'] as Color,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppColors.elevationLevel1,
                        ),
                        child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        c['sub'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTroupes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grup Tarling Populer',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Terfavorit hajatan Cirebon - Indramayu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (widget.onExploreTap != null) {
                    widget.onExploreTap!();
                  }
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Carousel Horizontal
        SizedBox(
          height: 310,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _artists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final artist = _artists[index];
                    return _buildTroupeCard(context, artist);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTroupeCard(BuildContext context, ArtistProfileModel artist) {
    final isFavorite = _favoriteIds.contains(artist.id);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppColors.elevationLevel1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 Thumbnail Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHigh,
                  child: artist.avatarUrl != null && artist.avatarUrl!.startsWith('http')
                      ? Image.network(
                          artist.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderStage(),
                        )
                      : _buildPlaceholderStage(),
                ),
              ),
              // Category tag pill top left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    artist.category,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Favorite button top right
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isFavorite) {
                        _favoriteIds.remove(artist.id);
                      } else {
                        _favoriteIds.add(artist.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Troupe Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        artist.displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 13, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${artist.baseDistrict ?? ''}, ${artist.baseCity}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 3),
                    Text(
                      artist.ratingAvg.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${artist.totalJob} ulasan)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Price & Detail Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mulai dari', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
                          Text(
                            CurrencyFormatter.formatCompact(artist.priceMin),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArtistDetailScreen(artist: artist),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(64, 30),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          elevation: 0,
                        ),
                        child: Text('Detail', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderStage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8B1E1E), Color(0xFFD4A017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white70, size: 48),
      ),
    );
  }

  Widget _buildAudioSampleStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF22252A), // Dark Charcoal Capsule from Stitch
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppColors.elevationLevel2,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                setState(() => _isPlayingAudio = !_isPlayingAudio);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isPlayingAudio
                          ? 'Memutar sampel live: Keloas - Dian Anic'
                          : 'Sampel audio dijeda.',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlayingAudio ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AUDIO SAMPLE LIVE',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.secondaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '03:45',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Keloas - Dian Anic (Live Hajat Jatibarang)',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Animated sound wave bars
                  Row(
                    children: List.generate(12, (index) {
                      final heights = [8.0, 16.0, 12.0, 6.0, 14.0, 18.0, 10.0, 15.0, 7.0, 16.0, 11.0, 5.0];
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 3,
                        height: _isPlayingAudio ? heights[index % heights.length] : 4.0,
                        decoration: BoxDecoration(
                          color: index % 3 == 0 ? AppColors.primaryLight : AppColors.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHajatGuide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan & Keamanan Booking',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppColors.elevationLevel1,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.calendar_today, color: AppColors.tertiary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu Terbaik Booking Orkes',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Untuk bulan hajat (Rayagung & Syawal), amankan tanggal minimal 3-6 bulan sebelum hari H agar sinden & kendang utama tidak bentrok.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // 3 Trust Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _trustItem(Icons.verified_user, 'Kontrak Jelas', 'Resmi & Sah'),
                    _trustItem(Icons.lock, 'DP Aman 20%', 'Sistem Escrow'),
                    _trustItem(Icons.handshake, 'Pelunasan Cash', 'Di Lokasi Hajat'),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FaqScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Pusat Bantuan & Tanya Jawab',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.onSurfaceVariant),
                      ],
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

  Widget _trustItem(IconData icon, String title, String sub) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  void _showCalendarAdviceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Kalender Tanggal Baik Hajatan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Musim hajatan Pantura (Cirebon & Indramayu) memiliki tanggal-tanggal padat di mana jadwal grup tarling cepat terisi penuh.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Text('Bulan Rayagung & Dzulhijjah: Puncak pernikahan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppColors.tertiary),
                        SizedBox(width: 8),
                        Text('Bulan Syawal & Mulud: Ramai khitanan & syukuran', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                  ),
                  child: Text('Mengerti', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
