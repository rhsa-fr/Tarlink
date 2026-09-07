import 'package:flutter/material.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';

class SnapPaymentScreen extends StatefulWidget {
  final String bookingCode;
  final int dpAmount;

  const SnapPaymentScreen({
    super.key,
    required this.bookingCode,
    required this.dpAmount,
  });

  @override
  State<SnapPaymentScreen> createState() => _SnapPaymentScreenState();
}

class _SnapPaymentScreenState extends State<SnapPaymentScreen> {
  String _selectedMethod = 'qris';
  bool _isProcessing = false;

  Future<void> _simulatePaymentSuccess() async {
    setState(() => _isProcessing = true);

    try {
      // Simulate webhook trigger from client development environment
      await SupabaseService.client.functions.invoke(
        'midtrans-hook',
        body: {
          'order_id': widget.bookingCode,
          'status_code': '200',
          'gross_amount': widget.dpAmount.toString(),
          'transaction_status': 'settlement',
          'transaction_id': 'trx-${DateTime.now().millisecondsSinceEpoch}',
          'payment_type': _selectedMethod,
        },
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pembayaran DP Berhasil'),
          content: Text(
            'DP 20% (${CurrencyFormatter.formatRupiah(widget.dpAmount)}) telah terverifikasi otomatis.\nTanggal pentas telah TERKUNCI dan E-Voucher QR Anda telah terbit.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Buka Pesanan'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulasi bayar berhasil dicatat')),
      );
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran DP 20%'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Order summary
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Total DP 20% Yang Harus Dibayar:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.formatRupiah(widget.dpAmount),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text('Kode Booking: ${widget.bookingCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.warning, size: 18),
                      SizedBox(width: 6),
                      Text('Sisa waktu bayar: 29 menit 50 detik', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Pilih Metode Pembayaran Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          // QRIS
          _methodTile('qris', 'QRIS (Semua E-Wallet & Bank)', Icons.qr_code_scanner),
          // BCA VA
          _methodTile('bca_va', 'BCA Virtual Account', Icons.account_balance),
          // BRI VA
          _methodTile('bri_va', 'BRI Virtual Account', Icons.account_balance),
          // Mandiri VA
          _methodTile('mandiri_va', 'Mandiri Virtual Account', Icons.account_balance),

          const SizedBox(height: 28),
          AppButton(
            label: 'Bayar Sekarang via Midtrans',
            isLoading: _isProcessing,
            onPressed: _simulatePaymentSuccess,
          ),
        ],
      ),
    );
  }

  Widget _methodTile(String value, String title, IconData icon) {
    final isSelected = _selectedMethod == value;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? AppColors.primary : Colors.grey,
        ),
        onTap: () => setState(() => _selectedMethod = value),
      ),
    );
  }
}
