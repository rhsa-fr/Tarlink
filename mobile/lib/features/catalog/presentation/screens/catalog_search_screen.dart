import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../data/models/artist_profile_model.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'artist_detail_screen.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../../core/widgets/tarlink_logo.dart';

class CatalogSearchScreen extends StatefulWidget {
  final CatalogRepository? repository;
  final String? initialCategory;

  const CatalogSearchScreen({super.key, this.repository, this.initialCategory});

  @override
  State<CatalogSearchScreen> createState() => _CatalogSearchScreenState();
}

class _CatalogSearchScreenState extends State<CatalogSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedCity;
  String? _selectedCategory;
  DateTime? _selectedDate;
  int? _maxBudget;
  String _currentSort = 'Rating Tertinggi';
  bool _onlyDp20 = false;

  bool _isLoading = false;
  List<ArtistProfileModel> _allArtists = [];
  List<ArtistProfileModel> _filteredArtists = [];
  final Set<String> _favoriteIds = {};
  String? _playingSampleId;

  final List<String> _cities = ['Semua Kota', 'Indramayu', 'Cirebon', 'Majalengka', 'Kuningan', 'Subang'];
  final List<Map<String, String>> _categories = [
    {'slug': '', 'name': 'Semua'},
    {'slug': 'tarling-dangdut', 'name': 'Dangdut Pantura'},
    {'slug': 'tarling-klasik', 'name': 'Tarling Klasik'},
    {'slug': 'organ-tunggal', 'name': 'Organ Tunggal'},
    {'slug': 'sandiwara-full', 'name': 'Sandiwara'},
    {'slug': 'biduan-solo', 'name': 'Biduan Solo'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _normalizeCategory(widget.initialCategory ?? '');
    _loadArtists();
  }

  @override
  void didUpdateWidget(covariant CatalogSearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = _normalizeCategory(widget.initialCategory ?? '');
      });
      _applyLocalFilters();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _normalizeCategory(String? cat) {
    if (cat == null || cat.isEmpty) return '';
    final lower = cat.toLowerCase().trim().replaceAll('_', '-');
    if (lower == 'sandiwara' || lower.contains('sandiwara')) return 'sandiwara-full';
    if (lower.contains('dangdut') || lower.contains('tarling-dangdut')) return 'tarling-dangdut';
    if (lower.contains('organ')) return 'organ-tunggal';
    if (lower.contains('klasik')) return 'tarling-klasik';
    if (lower.contains('biduan') || lower.contains('sinden')) return 'biduan-solo';
    if (lower.contains('mc') || lower.contains('pranata')) return 'mc-pranatacara';
    return lower;
  }

  Future<void> _loadArtists() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final repo = widget.repository ?? CatalogRepositoryImpl();
      final results = await repo.searchArtists();

      final Set<String> seenIds = {};
      final List<ArtistProfileModel> list = [];

      for (final a in results) {
        if (seenIds.add(a.id)) {
          list.add(a);
        }
      }

      _allArtists = list;
    } catch (e) {
      debugPrint('[CatalogSearch] Gagal mengambil data real dari database: $e');
      _allArtists = [];
    } finally {
      if (mounted) {
        _applyLocalFilters();
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyLocalFilters() {
    final query = _searchCtrl.text.trim().toLowerCase();
    List<ArtistProfileModel> list = List.from(_allArtists);

    if (query.isNotEmpty) {
      list = list.where((a) {
        final matchName = a.displayName.toLowerCase().contains(query);
        final matchCity = a.baseCity.toLowerCase().contains(query);
        final matchCat = a.categoryDisplay.toLowerCase().contains(query);
        final matchCatRaw = a.category.toLowerCase().contains(query);
        final matchDist = (a.baseDistrict ?? '').toLowerCase().contains(query);
        final matchDesc = (a.description ?? '').toLowerCase().contains(query);
        final matchCoverage = a.coverageCities.any((c) => c.toLowerCase().contains(query));
        return matchName || matchCity || matchCat || matchCatRaw || matchDist || matchDesc || matchCoverage;
      }).toList();
    }

    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      final targetCat = _normalizeCategory(_selectedCategory);
      list = list.where((a) {
        final aCat = _normalizeCategory(a.category);
        return aCat == targetCat || a.category == _selectedCategory;
      }).toList();
    }

    if (_selectedCity != null && _selectedCity != 'Semua Kota') {
      final cityLower = _selectedCity!.toLowerCase();
      list = list.where((a) {
        final matchBase = a.baseCity.toLowerCase() == cityLower;
        final matchCoverage = a.coverageCities.any((c) => c.toLowerCase() == cityLower);
        return matchBase || matchCoverage;
      }).toList();
    }

    if (_maxBudget != null && _maxBudget! > 0) {
      list = list.where((a) => a.priceMin <= _maxBudget!).toList();
    }

    if (_onlyDp20) {
      list = list.where((a) => a.autoAccept).toList();
    }

    // Sorting
    if (_currentSort == 'Rating Tertinggi') {
      list.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    } else if (_currentSort == 'Harga Terendah') {
      list.sort((a, b) => a.priceMin.compareTo(b.priceMin));
    } else if (_currentSort == 'Paling Populer') {
      list.sort((a, b) => b.totalJob.compareTo(a.totalJob));
    }

    if (!mounted) return;
    setState(() => _filteredArtists = list);
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCity != null && _selectedCity != 'Semua Kota') count++;
    if (_selectedDate != null) count++;
    if (_maxBudget != null && _maxBudget! > 0) count++;
    if (_onlyDp20) count++;
    return count;
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    }
  }

  String _monthName(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }

  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String tempCity = _selectedCity ?? 'Semua Kota';
        DateTime? tempDate = _selectedDate;
        double tempBudget = (_maxBudget ?? 30000000).toDouble();
        bool tempDp = _onlyDp20;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Pencarian Pentas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  const SizedBox(height: 8),

                  // Kota / Wilayah
                  Text(
                    'Wilayah Pentas Pantura',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cities.map((city) {
                      final isSel = tempCity == city;
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSel,
                        selectedColor: AppColors.primary,
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSel ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        backgroundColor: AppColors.surfaceContainerLow,
                        onSelected: (val) {
                          if (val) setModalState(() => tempCity = city);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Tanggal Pentas
                  Text(
                    'Tanggal Pentas Hajatan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => tempDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            tempDate == null ? 'Pilih Tanggal Acara' : _formatDate(tempDate!),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: tempDate == null ? AppColors.textMuted : AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          if (tempDate != null)
                            GestureDetector(
                              onTap: () => setModalState(() => tempDate = null),
                              child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Budget Maksimal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget Maksimal',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(tempBudget.round()),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempBudget,
                    min: 1500000,
                    max: 30000000,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceContainerHigh,
                    onChanged: (val) => setModalState(() => tempBudget = val),
                  ),
                  const SizedBox(height: 12),

                  // Switch DP 20%
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Bisa DP 20% / Instant Booking',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Konfirmasi instan tanpa nego ronde',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    value: tempDp,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => setModalState(() => tempDp = val),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCity = 'Semua Kota';
                              _selectedDate = null;
                              _maxBudget = null;
                              _onlyDp20 = false;
                            });
                            _applyLocalFilters();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCity = tempCity;
                              _selectedDate = tempDate;
                              _maxBudget = tempBudget.round();
                              _onlyDp20 = tempDp;
                            });
                            _applyLocalFilters();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Terapkan Filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            boxShadow: const [
              BoxShadow(color: Color(0x0A22252A), blurRadius: 8, offset: Offset(0, 1)),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const TarlinkLogo(height: 28),
                  const Spacer(),
                  // Lokasi Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCity == null || _selectedCity == 'Semua Kota' ? 'Indramayu & Cirebon' : _selectedCity!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22, color: AppColors.textPrimary),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountScreen()));
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Sticky Top Section: Search Input + Genre Chips + Sub-filter bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                // Search Input Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A22252A), blurRadius: 6, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Cari nama grup, sinden, orkes...',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textMuted),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (_) => _applyLocalFilters(),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            _applyLocalFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Horizontal Genre Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = (_selectedCategory ?? '') == cat['slug'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(9999),
                          onTap: () {
                            setState(() => _selectedCategory = isSelected ? '' : cat['slug']);
                            _applyLocalFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: const [
                                BoxShadow(color: Color(0x0822252A), blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                            child: Text(
                              cat['name']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Sub-Filter Action Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter Button with Badge
                      InkWell(
                        borderRadius: BorderRadius.circular(9999),
                        onTap: _openFilterModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0FBD4024), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tune, size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Filter',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (_activeFilterCount > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Sort Trigger Popup
                      PopupMenuButton<String>(
                        initialValue: _currentSort,
                        onSelected: (val) {
                          setState(() => _currentSort = val);
                          _applyLocalFilters();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'Rating Tertinggi', child: Text('Rating Tertinggi')),
                          PopupMenuItem(value: 'Harga Terendah', child: Text('Harga Terendah')),
                          PopupMenuItem(value: 'Paling Populer', child: Text('Paling Populer')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0822252A), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Urutkan: ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _currentSort,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.expand_more, size: 16, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Quick Toggle DP 20%
                      InkWell(
                        borderRadius: BorderRadius.circular(9999),
                        onTap: () {
                          setState(() => _onlyDp20 = !_onlyDp20);
                          _applyLocalFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _onlyDp20 ? AppColors.secondaryFixed : Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0822252A), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 15,
                                color: _onlyDp20 ? AppColors.onSecondaryFixed : AppColors.secondaryDark,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Bisa DP 20%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _onlyDp20 ? AppColors.onSecondaryFixed : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Quick Toggle Tanggal
                      InkWell(
                        borderRadius: BorderRadius.circular(9999),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                            _applyLocalFilters();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedDate != null ? AppColors.tertiaryFixed : Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0822252A), blurRadius: 4, offset: Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 15,
                                color: _selectedDate != null ? AppColors.onTertiaryFixed : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _selectedDate != null ? _formatDate(_selectedDate!) : 'Tanggal Tersedia',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDate != null ? AppColors.onTertiaryFixed : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Context Status Ribbon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _selectedDate == null ? 'Musim Pentas Pantura' : _formatDate(_selectedDate!),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Pasaran Manis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Ditemukan ${_filteredArtists.length} Orkes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Listing Cards Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredArtists.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadArtists,
                        color: AppColors.primary,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                            const Center(
                              child: Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'Tidak ada grup yang sesuai filter',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Coba ubah kata kunci atau reset filter pencarian',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Reset Semua Filter'),
                                onPressed: () {
                                  setState(() {
                                    _searchCtrl.clear();
                                    _selectedCategory = '';
                                    _selectedCity = 'Semua Kota';
                                    _selectedDate = null;
                                    _maxBudget = null;
                                    _onlyDp20 = false;
                                  });
                                  _applyLocalFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadArtists,
                        color: AppColors.primary,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _filteredArtists.length,
                          itemBuilder: (context, index) {
                            final artist = _filteredArtists[index];
                            return _buildStitchArtistCard(artist, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStitchArtistCard(ArtistProfileModel artist, int index) {
    final isFav = _favoriteIds.contains(artist.id);
    final isPlaying = _playingSampleId == artist.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0C22252A), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 Stage Banner with Overlays
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: (artist.avatarUrl != null && artist.avatarUrl!.startsWith('http'))
                    ? Image.network(
                        artist.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.theater_comedy, color: AppColors.textMuted, size: 48),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF8B1E1E), Color(0xFFD4A017)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.theater_comedy, color: Colors.white70, size: 48),
                        ),
                      ),
              ),
              // Gradient Scrim
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x40000000),
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                    ),
                  ),
                ),
              ),
              // Badges Top Left
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        artist.categoryDisplay,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 11, color: AppColors.onSecondaryContainer),
                          const SizedBox(width: 3),
                          Text(
                            'Pilihan Juara',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite Button Top Right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFav) {
                        _favoriteIds.remove(artist.id);
                      } else {
                        _favoriteIds.add(artist.id);
                      }
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFav ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // Audio Sample Floating Pill Banner
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xE6191C21),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _playingSampleId = isPlaying ? null : artist.id;
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sample Audio Live Pantura',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Live Pentas Tarling Indramayu',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                color: const Color(0xFFE1E2E9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '03:45',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.secondaryFixed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Card Body Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title, Verified, Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  artist.displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                '${artist.baseDistrict ?? "Pusat"}, ${artist.baseCity}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFF6BE39)),
                          const SizedBox(width: 3),
                          Text(
                            artist.ratingAvg.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' (${artist.totalJob})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Trust Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: AppColors.tertiaryDark),
                      const SizedBox(width: 6),
                      Text(
                        '✓ Siap tampil di hajatan Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onTertiaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Specs Pills
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSpecChip('24 Personil'),
                    _buildSpecChip('Sound 15.000W'),
                    _buildSpecChip('Bisa DP 20%'),
                  ],
                ),
                const Divider(height: 20),

                // Pricing & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mulai dari',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(artist.priceMin),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '/ pementasan',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        elevation: 1,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtistDetailScreen(
                              artist: artist,
                              repository: widget.repository,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Lihat Detail',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

