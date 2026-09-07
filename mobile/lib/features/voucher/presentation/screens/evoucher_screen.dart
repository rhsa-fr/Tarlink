import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/evoucher_model.dart';
import '../../data/services/offline_voucher_service.dart';

class EVoucherScreen extends StatefulWidget {
  final EVoucherModel voucher;

  const EVoucherScreen({super.key, required this.voucher});

  @override
  State<EVoucherScreen> createState() => _EVoucherScreenState();
}

class _EVoucherScreenState extends State<EVoucherScreen> {
  final _offlineService = OfflineVoucherService();
  bool _isSavedOffline = false;

  @override
  void initState() {
    super.initState();
    _saveForOffline();
  }

  Future<void> _saveForOffline() async {
    await _offlineService.saveVoucherOffline(widget.voucher);
    if (mounted) {
      setState(() => _isSavedOffline = true);
    }
  }

  Future<void> _shareVoucher(EVoucherModel v) async {
    final text = '''
🎭 *E-VOUCHER RESMI TARLINGBOOK*
*Nomor Tiket:* ${v.code}

*Grup Seni:* ${v.artistName}
*Paket:* ${v.packageName}
*Tanggal Pentas:* ${v.eventDate}
*Lokasi Hajatan:* ${v.venueAddress} (${v.zone})
*Status:* DP 20% LUNAS (${CurrencyFormatter.formatRupiah(v.dpPaid)})
*Sisa Bayar Cash di Lokasi:* ${CurrencyFormatter.formatRupiah(v.remainingCash)}

_Tunjukkan QR E-Voucher pada aplikasi TarlingBook saat pimpinan grup tiba di lokasi hajatan._
''';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'E-Voucher Booking ${v.artistName} - ${v.eventDate}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.voucher;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Voucher Pentas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Bagikan E-Voucher',
            onPressed: () => _shareVoucher(v),
          ),
          if (_isSavedOffline)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.offline_pin, color: AppColors.success, size: 20),
                  SizedBox(width: 4),
                  Text('Tersimpan Offline', style: TextStyle(fontSize: 12, color: AppColors.success)),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          v.code,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // QR Code
                      QrImageView(
                        data: v.voucherQrData,
                        version: QrVersions.auto,
                        size: 220.0,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.secondaryDark,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        'Tunjukkan QR ini ke Pimpinan Grup saat Hari H',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 32),

                      // Booking Summary
                      _buildInfoRow('Nama Grup:', v.artistName, isBold: true),
                      const SizedBox(height: 8),
                      _buildInfoRow('Paket:', v.packageName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Tanggal Pentas:', v.eventDate, isBold: true),
                      const SizedBox(height: 8),
                      _buildInfoRow('Lokasi & Zona:', '${v.venueAddress} (${v.zone})'),
                      const Divider(height: 24),
                      _buildInfoRow('Total Kontrak:', CurrencyFormatter.formatRupiah(v.totalPrice)),
                      const SizedBox(height: 8),
                      _buildInfoRow('DP 20% (Lunas):', CurrencyFormatter.formatRupiah(v.dpPaid),
                          valueColor: AppColors.success),
                      const SizedBox(height: 8),
                      _buildInfoRow('Sisa Bayar di Lokasi:', CurrencyFormatter.formatRupiah(v.remainingCash),
                          valueColor: AppColors.primaryDark, isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'E-Voucher ini tetap dapat dibuka tanpa koneksi internet (offline cache).',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _shareVoucher(v),
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  'Bagikan ke WhatsApp Panitia / Keluarga',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
