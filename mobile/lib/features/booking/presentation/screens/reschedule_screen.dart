import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class RescheduleScreen extends StatefulWidget {
  final String bookingId;
  final String bookingCode;
  final String artistName;
  final DateTime originalEventDate;
  final int totalPrice;

  const RescheduleScreen({
    super.key,
    required this.bookingId,
    required this.bookingCode,
    required this.artistName,
    required this.originalEventDate,
    required this.totalPrice,
  });

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  final _reasonCtrl = TextEditingController();
  DateTime? _newDate;
  bool _isSubmitting = false;

  int get _rescheduleFee => (widget.totalPrice * 0.10).round();

  bool get _isHMinus7Eligible {
    final diffDays = widget.originalEventDate.difference(DateTime.now()).inDays;
    return diffDays >= 7;
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleReschedule() async {
    if (!_isHMinus7Eligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reschedule hanya dapat diajukan minimal H-7 sebelum hari H acara.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_newDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal baru terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate RPC

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reschedule Diajukan'),
        content: Text(
          'Permintaan ganti tanggal ke ${DateFormat('dd MMMM yyyy', 'id_ID').format(_newDate!)} telah diajukan ke pimpinan ${widget.artistName}.\nBiaya admin reschedule 10% (${CurrencyFormatter.formatRupiah(_rescheduleFee)}) ditambahkan ke tagihan invoice.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diffDays = widget.originalEventDate.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Reschedule Jadwal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info Aturan H-7 & Fee 10%
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isHMinus7Eligible ? AppColors.primaryLight : Colors.red.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _isHMinus7Eligible ? AppColors.primary : AppColors.error),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isHMinus7Eligible ? Icons.info_outline : Icons.warning_amber,
                      color: _isHMinus7Eligible ? AppColors.primaryDark : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isHMinus7Eligible ? 'Ketentuan Reschedule H-7' : 'Batas Waktu Reschedule Lewat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _isHMinus7Eligible ? AppColors.primaryDark : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Sisa waktu menuju hari H: $diffDays hari lagi. Sesuai aturan PRD, pengajuan ganti tanggal wajib minimal H-7 acara dan dikenakan biaya penyesuaian jadwal 10% dari total kontrak.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Detail Booking
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Kode Pesanan:', widget.bookingCode),
                  const SizedBox(height: 8),
                  _row('Grup Kesenian:', widget.artistName),
                  const SizedBox(height: 8),
                  _row('Tanggal Awal:', DateFormat('dd MMMM yyyy', 'id_ID').format(widget.originalEventDate)),
                  const Divider(height: 24),
                  _row('Total Nilai Kontrak:', CurrencyFormatter.formatRupiah(widget.totalPrice)),
                  const SizedBox(height: 8),
                  _row('Biaya Reschedule (10%):', CurrencyFormatter.formatRupiah(_rescheduleFee), isBold: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Pilih Tanggal Baru (Wajib Hijau)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _isHMinus7Eligible
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: widget.originalEventDate.add(const Duration(days: 14)),
                      firstDate: DateTime.now().add(const Duration(days: 7)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _newDate = picked);
                    }
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _newDate == null
                          ? 'Ketuk untuk Pilih Tanggal Baru'
                          : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_newDate!),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _newDate == null ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          AppTextField(
            label: 'Alasan Reschedule (Opsional)',
            controller: _reasonCtrl,
            hint: 'Misal: Keluarga ada hajat lain / pengunduran tanggal',
          ),

          const SizedBox(height: 28),
          AppButton(
            label: 'Ajukan Reschedule (+Fee 10%)',
            isLoading: _isSubmitting,
            onPressed: _isHMinus7Eligible ? _handleReschedule : null,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
