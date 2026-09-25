import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';

class CashConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final String bookingCode;
  final int remainingCashAmount;

  const CashConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.bookingCode,
    required this.remainingCashAmount,
  });

  @override
  State<CashConfirmationScreen> createState() => _CashConfirmationScreenState();
}

class _CashConfirmationScreenState extends State<CashConfirmationScreen> {
  final _amountCtrl = TextEditingController();
  bool _hasAgreed = false;
  bool _isSubmitting = false;
  String? _simulatedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.remainingCashAmount.toString();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitConfirmation() async {
    if (!_hasAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang persetujuan serah-terima tunai terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = BookingRepositoryImpl();
      final amount = int.tryParse(_amountCtrl.text.trim()) ?? widget.remainingCashAmount;
      final photoUrl = _simulatedPhotoUrl ?? 'https://storage.tarlingbook.id/cash-receipts/mock-kwitansi.jpg';

      await repo.confirmCashPayment(
        bookingId: widget.bookingId,
        cashAmount: amount,
        receiptPhotoUrl: photoUrl,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pelunasan Tunai Berhasil'),
          content: Text(
            'Pelunasan tunai sebesar ${CurrencyFormatter.formatRupiah(amount)} telah dicatat.\nStatus acara kini berstatus SELESAI (COMPLETED). Dana sisa DP akan dicairkan otomatis ke grup pada H+2.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal konfirmasi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pelunasan Tunai'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pesanan: ${widget.bookingCode}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nominal Tagihan Sisa Cash: ${CurrencyFormatter.formatRupiah(widget.remainingCashAmount)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Diserahkan langsung secara tunai antara Sohibul Hajat dan Pimpinan Grup di lokasi.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Nominal Tunai Diterima / Diserahkan (Rp)',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text(
              'Foto Kwitansi / Bukti Serah Terima Fisik',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _simulatedPhotoUrl = 'https://mock.storage/kwitansi-${widget.bookingCode}.jpg';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Foto kwitansi berhasil dilampirkan')),
                );
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _simulatedPhotoUrl != null ? Icons.check_circle : Icons.camera_alt,
                      color: _simulatedPhotoUrl != null ? AppColors.success : AppColors.primary,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _simulatedPhotoUrl != null ? 'Foto Kwitansi Terlampir' : 'Ketuk untuk Ambil Foto Kwitansi',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _hasAgreed,
              activeColor: AppColors.primary,
              title: const Text(
                'Saya menyatakan bahwa pelunasan tunai telah diselesaikan secara penuh di lokasi hajatan hari ini.',
                style: TextStyle(fontSize: 13),
              ),
              onChanged: (val) => setState(() => _hasAgreed = val ?? false),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Konfirmasi Lunas Dua Sisi',
              isLoading: _isSubmitting,
              onPressed: _submitConfirmation,
            ),
          ],
        ),
      ),
    );
  }
}
