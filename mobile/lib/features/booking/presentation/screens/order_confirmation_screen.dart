import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/tarlink_logo.dart';
import '../../../voucher/data/models/evoucher_model.dart';
import '../../../voucher/presentation/screens/evoucher_screen.dart';
import '../../data/models/booking_model.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final BookingModel? booking;
  final String? artistName;
  final String? packageName;
  final String? packageSpec;
  final String? customerName;
  final String? customerPhone;

  const OrderConfirmationScreen({
    super.key,
    this.booking,
    this.artistName,
    this.packageName,
    this.packageSpec,
    this.customerName,
    this.customerPhone,
  });

  String get _bookingCode => booking?.code ?? 'TRL-20261115-8892';
  String get _groupName => artistName ?? 'Dian Anic & Anica Nada';
  String get _planName => packageName ?? 'Paket Komplit Siang-Malam';
  String get _spec => packageSpec ?? 'Sound System 10.000W + 8 Sinden';
  DateTime get _eventDate => booking?.eventDate ?? DateTime.now().add(const Duration(days: 30));
  String get _address => booking?.venueAddress ?? 'Jl. Sunan Gunung Jati No. 45, Kab. Cirebon';
  String get _buyerName => customerName ?? 'Budi Pratama';
  String get _buyerPhone => customerPhone ?? '0812-3456-7890';
  int get _totalPrice => booking?.totalPrice ?? 25000000;
  int get _dpAmount => booking?.dpAmount ?? 5000000;
  int get _remainingAmount => booking?.remainingAmount ?? 20000000;

  String _formatDate(DateTime date, String pattern) {
    try {
      return DateFormat(pattern, 'id_ID').format(date);
    } catch (_) {
      return DateFormat(pattern).format(date);
    }
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _bookingCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Kode $_bookingCode disalin ke clipboard!'),
          ],
        ),
        backgroundColor: AppColors.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEVoucher(BuildContext context) {
    final voucher = EVoucherModel(
      code: _bookingCode,
      voucherQrData: 'TRLKU-AUTH-$_bookingCode-${booking?.id ?? "local"}',
      artistName: _groupName,
      packageName: _planName,
      eventDate: _formatDate(_eventDate, 'EEEE, dd MMMM yyyy'),
      venueAddress: _address,
      zone: booking?.zone ?? 'Pantura Ring 1',
      totalPrice: _totalPrice,
      dpPaid: _dpAmount,
      remainingCash: _remainingAmount,
      customerName: _buyerName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EVoucherScreen(voucher: voucher)),
    );
  }

  Future<void> _shareBookingDetails() async {
    final text = '''
🎭 *BUKTI PESANAN TARLINGKU*
Nomor Booking: $_bookingCode
Grup Orkes: $_groupName
Paket: $_planName
Tanggal Hajat: ${_formatDate(_eventDate, 'EEEE, dd MMMM yyyy')}
Lokasi: $_address
Sohibul Hajat: $_buyerName ($_buyerPhone)

*Rincian Biaya:*
- Total Kontrak: ${CurrencyFormatter.formatRupiah(_totalPrice)}
- DP 20% (Lunas): ${CurrencyFormatter.formatRupiah(_dpAmount)}
- Sisa Cash H-1: ${CurrencyFormatter.formatRupiah(_remainingAmount)}

"Mugi lancar berkah hajatane, rame penontone, bungah atine."
TarlingKu • Mitra Seni Panggung Pantura
''';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Konfirmasi Pesanan TarlingKu $_bookingCode',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withAlpha(240),
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TarlinkLogo(height: 26, showSubtitle: true),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, size: 14, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'Pantura',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // 1. Celebratory Success Banner
            _buildCelebrationSection(context),

            const SizedBox(height: 16),

            // 2. Booking Code Card
            _buildBookingCodeCard(context),

            const SizedBox(height: 16),

            // 3. E-Voucher Ticket Card
            _buildTicketCard(context),

            const SizedBox(height: 16),

            // 4. Next Steps Card
            _buildNextStepsCard(context),

            const SizedBox(height: 24),

            // 5. Action Buttons
            _buildActionButtons(context),

            const SizedBox(height: 20),

            // 6. Pantura Blessing Footer
            _buildPanturaFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withAlpha(50),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x281F5D43),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 28),
            ),
            const Positioned(
              top: 0,
              right: 2,
              child: Text('✨', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tertiaryFixed,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 14, color: AppColors.onTertiaryFixed),
              SizedBox(width: 4),
              Text(
                'Jadwal Panggung Terkunci',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onTertiaryFixed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Pesanan Berhasil Dikonfirmasi!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: -0.3,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Jadwal panggung grup orkes Anda telah dikunci dan tercatat resmi di sistem TarlingKu. Selamat menyongsong hajatan meriah!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildBookingCodeCard(BuildContext context) {
    return Container(
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
              Text(
                'NOMOR BOOKING RESMI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'DP 20% Terbayar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onTertiaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _bookingCode,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _copyCode(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_copy, size: 14, color: AppColors.onSurface),
                        SizedBox(width: 4),
                        Text(
                          'Salin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurface),
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
    );
  }

  Widget _buildTicketCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevation2,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header E-Voucher Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.theater_comedy, color: AppColors.secondaryFixed, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'E-Voucher Pentas Tarling',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Text(
                    'Cirebon & Indramayu',
                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Troupe Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.music_note, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _groupName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _planName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.speaker_group, size: 12, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _spec,
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Perforated Ticket Notch Divider
          _buildTicketPerforation(),

          // Details List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date & Duration Grid
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Hari & Tanggal',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_eventDate, 'dd MMM yyyy'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              'Tanggal Baik Hajat',
                              style: TextStyle(fontSize: 10, color: AppColors.tertiary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule, size: 12, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Durasi Panggung',
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '09:00 - 23:00 WIB',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Sesi Siang & Malam',
                              style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildDetailRow(Icons.celebration, 'Jenis Hajatan', 'Pernikahan (Resepsi & Pentas Malam)'),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.place, 'Lokasi Panggung', _address),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.person, 'Pemesan / Sohibul Hajat', '$_buyerName ($_buyerPhone)'),

                const SizedBox(height: 14),

                // Financial Breakdown Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Kontrak Paket Orkes', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          Text(
                            CurrencyFormatter.formatRupiah(_totalPrice),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Uang Muka (DP 20% Terbayar)', style: TextStyle(fontSize: 12, color: AppColors.tertiary, fontWeight: FontWeight.w600)),
                          Text(
                            '- ${CurrencyFormatter.formatRupiah(_dpAmount)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sisa Pelunasan H-1',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                              Text(
                                'Dibayar cash saat gladi bersih panggung',
                                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          Text(
                            CurrencyFormatter.formatRupiah(_remainingAmount),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // QR Code Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: 'TRLKU-AUTH-$_bookingCode-${booking?.id ?? "local"}',
                          version: QrVersions.auto,
                          size: 140,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tunjukkan QR ini ke manajer orkes saat kedatangan tim H-1 gladi panggung',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
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

  Widget _buildTicketPerforation() {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: List.generate(
              28,
              (i) => Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: i.isEven ? AppColors.outlineVariant.withAlpha(120) : Colors.transparent,
                ),
              ),
            ),
          ),
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.secondary),
              SizedBox(width: 6),
              Text(
                'Langkah Selanjutnya',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildStepItem('1', 'Manajer $_groupName akan menghubungi Anda via WhatsApp H-3 untuk koordinasi susunan lagu (rundown).'),
          const SizedBox(height: 8),
          _buildStepItem('2', 'Tim teknisi panggung & sound tiba di lokasi pada H-1 pukul 16:00 WIB untuk instalasi daya listrik genset.'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.secondaryFixed,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Button Buka E-Voucher Offline
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.primary,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.qr_code, size: 18),
            label: const Text('Buka E-Voucher Panggung (Offline)', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _openEVoucher(context),
          ),
        ),

        const SizedBox(height: 10),

        // Button Bagikan Bukti Pesanan
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiaryFixed,
              foregroundColor: AppColors.onTertiaryFixed,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.share, size: 18, color: AppColors.tertiary),
            label: const Text('Bagikan Rincian Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _shareBookingDetails,
          ),
        ),

        const SizedBox(height: 10),

        // Button Kembali ke Beranda
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              elevation: 2,
            ),
            icon: const Icon(Icons.home, size: 18),
            label: const Text('Kembali ke Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ),
      ],
    );
  }

  Widget _buildPanturaFooter(BuildContext context) {
    return const Column(
      children: [
        Text(
          '"Mugi lancar berkah hajatane, rame penontone, bungah atine."',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
        ),
        SizedBox(height: 4),
        Text(
          'TarlingKu • Mitra Seni Panggung Pantura',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
        ),
      ],
    );
  }
}
