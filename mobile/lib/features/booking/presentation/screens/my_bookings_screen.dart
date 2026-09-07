import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../payment/presentation/screens/cash_confirmation_screen.dart';
import '../../../payment/presentation/screens/snap_payment_screen.dart';
import '../../../voucher/data/models/evoucher_model.dart';
import '../../../voucher/presentation/screens/evoucher_screen.dart';
import '../../../catalog/presentation/screens/review_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../auth/presentation/screens/account_screen.dart';
import '../../../chat_bot/presentation/screens/group_chat_screen.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository_impl.dart';
import 'order_confirmation_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _activeTab = 'akan-datang'; // 'akan-datang', 'selesai', 'batal'

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final repo = BookingRepositoryImpl(SupabaseService.client);
      final userId = SupabaseService.client.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000001';
      final list = await repo.getCustomerBookings(userId);
      setState(() => _bookings = list);
    } catch (_) {
      // Mock data matching Stitch design spec
      setState(() {
        _bookings = [
          BookingModel(
            id: 'b-01',
            code: 'TRG-20251115-8892',
            customerId: 'c1',
            artistId: 'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
            packageId: 'p1',
            eventDate: DateTime.now().add(const Duration(days: 8)),
            venueAddress: 'Jl. Sunan Gunung Jati No. 45, Gunungjati, Cirebon',
            city: 'Cirebon',
            district: 'Gunungjati',
            totalPrice: 25000000,
            dpAmount: 5000000,
            remainingAmount: 20000000,
            status: 'DP_PAID',
            bookingType: 'instant',
            evoucherCode: 'VCHR-TRG-20251115-8892',
          ),
          BookingModel(
            id: 'b-02',
            code: 'TRG-20251228-4412',
            customerId: 'c1',
            artistId: 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',
            packageId: 'p2',
            eventDate: DateTime.now().add(const Duration(days: 21)),
            venueAddress: 'Desa Kedawung RT 04/RW 02, Kedawung, Cirebon',
            city: 'Cirebon',
            district: 'Kedawung',
            totalPrice: 15000000,
            dpAmount: 3000000,
            remainingAmount: 12000000,
            status: 'WAITING_DP',
            bookingType: 'instant',
          ),
          BookingModel(
            id: 'b-03',
            code: 'TK-88219',
            customerId: 'c1',
            artistId: 'cccccccc-cccc-4ccc-cccc-cccccccccccc',
            packageId: 'p3',
            eventDate: DateTime.now().subtract(const Duration(days: 28)),
            venueAddress: 'Blok Manis, Jatibarang, Indramayu',
            city: 'Indramayu',
            district: 'Jatibarang',
            totalPrice: 18500000,
            dpAmount: 3700000,
            remainingAmount: 14800000,
            status: 'COMPLETED',
            bookingType: 'instant',
          ),
        ];
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<BookingModel> get _akanDatangBookings {
    return _bookings.where((b) => b.status == 'WAITING_DP' || b.status == 'DP_PAID' || b.status == 'ONGOING' || b.status == 'PENDING').toList();
  }

  List<BookingModel> get _selesaiBookings {
    return _bookings.where((b) => b.status == 'COMPLETED' || b.status == 'FULL_PAID').toList();
  }

  List<BookingModel> get _batalBookings {
    return _bookings.where((b) => b.status == 'CANCELLED' || b.status == 'EXPIRED').toList();
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    }
  }

  String _monthName(int m) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return (m >= 1 && m <= 12) ? months[m] : '';
  }

  String _getArtistImage(String? code) {
    if (code != null && code.contains('8892')) {
      return 'https://lh3.googleusercontent.com/aida-public/AB6AXuBp0NAD-PYrOt8OxsLU5TIRruCM-gz1WkTPwIGh9wlKmRvyHYg_-iUYYLwET9XTEsuiqt6AwtSnZ7nosJj-C2po1MLUaM9rk4biUzcAwQltiQe3q69jgWkKO539FLB4NCWDfxKRTHH7InxDzRa8Xq5qLnFbbyMEc2E9MgUIyj32RbfS-OCaF859BDaiS_717F7GE_tRn_Jm-RDnW5TJhOb54G01cHrPvz--gHrGOOz45e00Mly7D9TwYQ';
    }
    if (code != null && code.contains('4412')) {
      return 'https://lh3.googleusercontent.com/aida-public/AB6AXuCW4wRN2RNrJEApg1lu4bfBqu3HOZUi2BeWWCk8A1GfOvjg917NPSWh5dOTbinw5FYMyJ71uuIc3CPyyahfrAQdh7scB8jABNmTpfvCQMe-EED1colFA7gbYRVvGo3B4ooPKYlU-fRlGMkgeQp4X1ezJkoildyo72oRCLgBBXZO3dP0D0GuNcYRg0VmSJMTwc6Zmyvzok3eEUZCSaV01iNzTW-K5xQR5JiOzSMCfbBk0AnPWo557o5wOg';
    }
    return 'https://lh3.googleusercontent.com/aida-public/AB6AXuAVq58XZO1WMd_LIkRqx_xL_Gi5yHR-E-BZ-kNHEClyN5olBq5M5hv7b2RRnW9puslpY9s-38KPGoCr3a4Ek46J25vvE0Crnd92eqAwzKZ5L4JMx6bcTiTMRoKYVm9Izc-vZaKqD5SXQ-Lp3iLynE6B4GXONK5WvPH-xq2riyZg3mFHoKiEowFPQ7h-DaEkg9yDD6_dwOloOxqrNfxhhTG8lkx9k3uLFaZMnwMMSA6dpdF4REbZ4Ecxag';
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
                  Image.network(
                    'https://lh3.googleusercontent.com/aida/AEtjO1U9hAdtIEYquHeUCRgPfhZxGBsHOmAADGKpUOXlxxQrh71SIu4_wShAts8QS54rNh23MrcZskE3M6ov5AqlwCDdrVDAf8vhR4voMYu0xLS7UWbhOf4osQiDXN3BUD4MQqOZV9xWkMVSFbg2QXmUjJ2y8T4oh0kKR2zin028bWLi131L8boqGFHiNQmDTm4ms-s7VczNNJV4WtCodTDn2hxkXdpV-RGjorU7nkzSI7HdIOm6l9qDCeDruOK1',
                    height: 32,
                    errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TarlingKu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Pesanan Saya',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.04 * 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                          'Indramayu & Cirebon',
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
                      backgroundImage: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDQzv_Dk0O_iXgTvC2fX5q2Ra5nMhk0V6gWLe22OVFVSbSF0uGiICiPoi-UUFv3veiiDLTJqejkCV4MCYKOKOJIUQn5K7h-ZJiGYo7mc8JnjyW6UE3Usc7hl38gAlBlVRASmzj85_FjCpyZw974XN_6-cw2aiGefOM5C2Dh92yexki3Qf4kyaDjbFo8RAQx-uq3P-CNFjPKCjR2GOEWbfp5wUoP_srtQpXwtk4lJdwcTi8sa7Hp5MXosw',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Subtitle Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pesanan Saya',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Daftar booking panggung & jadwal pentas orkes Anda',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_available, color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                ),

                // Quick Trust Cue Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user, color: AppColors.secondary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Jaminan Pentas Resmi & Berizin Polsek',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Bantuan 24/7',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Segmented Tab Navigation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Akan Datang', 'akan-datang', _akanDatangBookings.length),
                        _buildTabButton('Selesai', 'selesai', _selesaiBookings.length),
                        _buildTabButton('Batal', 'batal', _batalBookings.length),
                      ],
                    ),
                  ),
                ),

                // Cards List View
                Expanded(
                  child: _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String label, String tabKey, int count) {
    final isActive = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isActive
                ? const [BoxShadow(color: Color(0x1FBD4024), blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<BookingModel> list;
    if (_activeTab == 'akan-datang') {
      list = _akanDatangBookings;
    } else if (_activeTab == 'selesai') {
      list = _selesaiBookings;
    } else {
      list = _batalBookings;
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Belum ada pesanan pada tab ini.',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];
        return _buildStitchBookingCard(b);
      },
    );
  }

  Widget _buildStitchBookingCard(BookingModel b) {
    final photoUrl = _getArtistImage(b.code);
    final isWaitingDp = b.status == 'WAITING_DP';
    final isConfirmed = b.status == 'DP_PAID' || b.status == 'ONGOING';
    final isCompleted = b.status == 'COMPLETED' || b.status == 'FULL_PAID';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0A22252A), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge & Countdown/Lock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isWaitingDp) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.onSecondaryFixed),
                      const SizedBox(width: 4),
                      Text(
                        'Menunggu Pembayaran DP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSecondaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, size: 12, color: Color(0xFF93000A)),
                      const SizedBox(width: 4),
                      Text(
                        '02:45:10',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF93000A),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isConfirmed) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppColors.onTertiaryFixed),
                      const SizedBox(width: 4),
                      Text(
                        'Terkonfirmasi (DP 20% Terbayar)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onTertiaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.lock, size: 13, color: AppColors.tertiaryDark),
                    const SizedBox(width: 3),
                    Text(
                      'Jadwal Terkunci',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tertiaryDark,
                      ),
                    ),
                  ],
                ),
              ] else if (isCompleted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Pentas Selesai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'ID: #${b.code}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    b.status,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Troupe Info & Image Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surfaceContainerHigh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.code.contains('8892')
                          ? 'Dian Anic & Anica Nada'
                          : b.code.contains('4412')
                              ? 'Susi Arzety & Arzety Nada'
                              : 'Rolani Diva & Orkes Pantura',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.music_note, size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Paket Komplit Siang-Malam (Hajat)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(b.eventDate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${b.district}, ${b.city}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Specs or Equipment Chips (for confirmed bookings)
          if (isConfirmed) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speaker, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Sound 15.000W + Genset',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.groups, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '6 Sinden & 14 Musisi',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Financial Summary Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWaitingDp ? 'Nominal Wajib DP (20%)' : 'Total Nilai Kontrak',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(isWaitingDp ? b.dpAmount : b.totalPrice),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isWaitingDp ? AppColors.primaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isWaitingDp ? 'Total Kontrak' : 'Sisa Pelunasan Cash (Lokasi)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(isWaitingDp ? b.totalPrice : b.remainingAmount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isConfirmed ? AppColors.tertiaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons cluster
          if (isWaitingDp) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderConfirmationScreen(
                            booking: b,
                            artistName: 'Susi Arzety & Arzety Nada',
                            packageName: 'Paket Reguler Siang (Khitanan)',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Lihat Detail',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payments, size: 16),
                    label: Text(
                      'Bayar Sekarang',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SnapPaymentScreen(
                            bookingCode: b.code,
                            dpAmount: b.dpAmount,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else if (isConfirmed) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: Text(
                      'E-Voucher & QR',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      final voucher = EVoucherModel(
                        code: b.code,
                        voucherQrData: 'TRG-AUTH-${b.code}-${b.dpAmount}',
                        artistName: 'Dian Anic & Anica Nada',
                        packageName: 'Paket Komplit Siang-Malam',
                        eventDate: DateFormat('dd MMM yyyy').format(b.eventDate),
                        venueAddress: b.venueAddress,
                        zone: b.zone ?? 'Ring 1',
                        totalPrice: b.totalPrice,
                        dpPaid: b.dpAmount,
                        remainingCash: b.remainingAmount,
                        customerName: 'Bpk. Sohibul Hajat',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EVoucherScreen(voucher: voucher)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.chat, size: 16),
                    label: Text(
                      'Hubungi Manajer',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatScreen(
                            artistName: b.code.contains('8892')
                                ? 'Dian Anic & Anica Nada'
                                : b.code.contains('4412')
                                    ? 'Susi Arzety & Arzety Nada'
                                    : 'Rolani Diva & Orkes Pantura',
                            bookingCode: b.code,
                            eventDate: DateFormat('dd MMM yyyy').format(b.eventDate),
                            venue: '${b.district}, ${b.city}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.receipt_long, size: 14, color: AppColors.textSecondary),
                label: Text(
                  'Konfirmasi Pelunasan Tunai di Lokasi',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CashConfirmationScreen(
                        bookingId: b.id,
                        bookingCode: b.code,
                        remainingCashAmount: b.remainingAmount,
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (isCompleted) ...[
            // Star rating prompt
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bagaimana kemeriahan pentas ini?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSecondaryFixed,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(Icons.star, size: 14, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderConfirmationScreen(
                            booking: b,
                            artistName: 'Rolani Diva & Orkes Pantura',
                            packageName: 'Pentas Fullday',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Pesan Lagi',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: Text(
                      'Beri Ulasan',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryContainer,
                      foregroundColor: AppColors.onSecondaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(
                            bookingId: b.id,
                            artistId: b.artistId,
                            artistName: 'Rolani Diva & Orkes Pantura',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
