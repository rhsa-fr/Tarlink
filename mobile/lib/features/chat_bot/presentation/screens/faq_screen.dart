import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _expandedIndices = {0}; // First one open by default matching Stitch

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana jika orkes tarling berhalangan hadir di hari H?',
      'a': 'TarlingKu memberikan jaminan 100% armada pengganti orkes setara dari Paguyuban Seni Pantura atau garansi refund penuh tanpa potongan jika terjadi kendala luar biasa dari pihak grup musik. Tim lapangan siaga radius 25 km.',
      'badge': 'Jaminan Paguyuban TarlingKu',
    },
    {
      'q': 'Kapan sisa pelunasan harus diserahkan ke pimpinan grup?',
      'a': 'Pelunasan sisa biaya pentas (setelah DP 20% online) diserahkan secara tunai (cash) langsung kepada pimpinan sanggar di lokasi hajat saat grup tiba dan sound check, dicatat lewat tombol konfirmasi dua sisi di aplikasi.',
      'badge': 'Pelunasan Lapangan',
    },
    {
      'q': 'Apakah harga paket sudah termasuk genset dan sound system?',
      'a': 'Setiap paket di lapak grup mencantumkan spesifikasi sound system (misal 5.000W / 10.000W / 15.000W). Jika membutuhkan genset diesel terpisah untuk area sawah/terop terbuka, opsi dapat dipilih di formulir booking.',
      'badge': 'Rider Panggung',
    },
    {
      'q': 'Bagaimana pengurusan izin keramaian Polsek dan Desa?',
      'a': 'Setelah DP 20% lunas, E-Voucher resmi dapat diunduh sebagai lampiran pengantar izin keramaian desa dan Polsek setempat. Dokumen memuat nama pimpinan grup, izin paguyuban, dan jumlah personil.',
      'badge': 'Legalitas Hajat',
    },
    {
      'q': 'Apakah saya bisa mengajukan jadwal ulang (reschedule) jika hajatan diundur?',
      'a': 'Bisa. Pengajuan reschedule dapat dilakukan minimal H-7 sebelum hari H melalui menu Pesanan Saya, dengan biaya administrasi 10% dan persetujuan ketersediaan tanggal baru dari pimpinan grup.',
      'badge': 'Ketentuan Reschedule',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((f) {
      final q = f['q']!.toLowerCase();
      final a = f['a']!.toLowerCase();
      final s = _searchQuery.toLowerCase();
      return q.contains(s) || a.contains(s);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pusat Bantuan & Garansi Hajat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Quick Search & Guarantee Banner
            _buildHeroBanner(),

            const SizedBox(height: 20),

            // 2. Bento Grid Kategori Panduan (4 Cards)
            _buildCategoryGrid(),

            const SizedBox(height: 20),

            // 3. Protokol Keamanan Pentas Card
            _buildSecurityProtocolBanner(),

            const SizedBox(height: 24),

            // 4. FAQ Accordion List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pertanyaan Sering Diajukan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  '${filteredFaqs.length} Jawaban Pokok',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...filteredFaqs.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isExpanded = _expandedIndices.contains(idx);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isExpanded ? AppColors.primaryLight : AppColors.borderSubtle),
                  boxShadow: AppColors.elevationLevel1,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIndices.remove(idx);
                          } else {
                            _expandedIndices.add(idx);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['q']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: isExpanded ? AppColors.primary : AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 14, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['badge']!,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['a']!,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 13, color: AppColors.onSecondaryContainer),
                SizedBox(width: 4),
                Text(
                  'GARANSI PENTAS AMAN PANTURA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.onSecondaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Panduan Resmi Hajatan & Garansi Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Informasi lengkap seputar pemesanan panggung sandiwara, rekber DP aman, hingga perizinan desa.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          // Search Box
          TextField(
            controller: _searchCtrl,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Cari topik (DP, refund, izin desa, genset)...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {
        'title': 'Pemesanan Orkes',
        'desc': 'Alur booking grup, paket, & cek tanggal',
        'icon': Icons.theater_comedy,
        'color': AppColors.primary,
        'bg': AppColors.primaryLight,
      },
      {
        'title': 'Pembayaran & DP',
        'desc': 'Escrow rekber aman & pelunasan di lokasi',
        'icon': Icons.account_balance_wallet,
        'color': AppColors.secondaryDark,
        'bg': AppColors.secondaryLight,
      },
      {
        'title': 'Pembatalan & Refund',
        'desc': 'Kebijakan pengembalian & jadwal ulang',
        'icon': Icons.published_with_changes,
        'color': AppColors.tertiary,
        'bg': AppColors.tertiaryContainer.withValues(alpha: 0.25),
      },
      {
        'title': 'Izin Polsek & Desa',
        'desc': 'Surat paguyuban & izin keramaian',
        'icon': Icons.assignment,
        'color': const Color(0xFF22252A),
        'bg': AppColors.surfaceContainerHigh,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppColors.elevationLevel1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: c['bg'] as Color, borderRadius: BorderRadius.circular(10)),
                child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                c['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  c['desc'] as String,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.25),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityProtocolBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFBD4024), Color(0xFF9B280E)],
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.security, color: Colors.white),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Protokol Keamanan Pentas 100%',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 3),
                Text(
                  'Semua grup terikat kontrak paguyuban resmi Cirebon-Indramayu. Dana DP aman tersimpan hingga panggung selesai.',
                  style: TextStyle(color: Color(0xFFFFDAD2), fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
