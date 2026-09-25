import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/repositories/group_repository_impl.dart';

class RegisterStallScreen extends StatefulWidget {
  final String userId;

  const RegisterStallScreen({super.key, required this.userId});

  @override
  State<RegisterStallScreen> createState() => _RegisterStallScreenState();
}

class _RegisterStallScreenState extends State<RegisterStallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bankNoCtrl = TextEditingController();
  final _bankOwnerCtrl = TextEditingController();

  String _selectedCategory = 'sandiwara-full';
  String _selectedCity = 'Indramayu';
  String _selectedBank = 'BCA';
  bool _isKtpUploaded = false;
  String? _ktpUrl;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'slug': 'sandiwara-full', 'name': 'Sandiwara Full Pantura'},
    {'slug': 'tarling-dangdut', 'name': 'Tarling Dangdut Kombinasi'},
    {'slug': 'organ-tunggal', 'name': 'Organ Tunggal / Campursari'},
    {'slug': 'biduan-solo', 'name': 'Biduan Solo & MC'},
  ];

  final List<String> _cities = ['Indramayu', 'Cirebon', 'Majalengka', 'Kuningan', 'Subang'];
  final List<String> _banks = ['BCA', 'Bank Mandiri', 'BRI', 'BNI', 'Bank BJB Pantura'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    _bankNoCtrl.dispose();
    _bankOwnerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSimulateUploadKtp() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _isLoading = false;
      _isKtpUploaded = true;
      _ktpUrl = 'https://tarlingbook.id/storage/ktp-verifications/${widget.userId}_ktp.jpg';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto KTP pimpinan berhasil diunggah!')),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isKtpUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajib unggah foto KTP asli pimpinan sanggar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = GroupRepositoryImpl();
      await repo.registerStall(
        userId: widget.userId,
        displayName: _nameCtrl.text.trim(),
        category: _selectedCategory,
        baseCity: _selectedCity,
        baseDistrict: _districtCtrl.text.trim(),
        description: _addressCtrl.text.trim(),
        bankName: _selectedBank,
        bankNo: _bankNoCtrl.text.trim(),
        bankOwner: _bankOwnerCtrl.text.trim(),
        ktpUrl: _ktpUrl,
      );

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Pengajuan Terkirim'),
            ],
          ),
          content: const Text(
            'Lapak Anda telah didaftarkan dengan status PENDING.\n\nAdmin Pasar Pantura akan memeriksa keaslian KTP Pimpinan Sanggar dalam 1x24 jam. Setelah disetujui, akun Anda otomatis menjadi Pimpinan Grup dan menu Lapak Grup akan terbuka penuh.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan lapak: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buka Lapak Seni Pantura'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Banner Edukasi
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(80)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.primaryDark, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pendaftaran lapak memerlukan verifikasi KTP Pimpinan untuk melindungi hak pementasan dan pencairan DP aman.',
                      style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Identitas Grup
            const Text(
              '1. Identitas Sanggar / Grup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Nama Sanggar / Grup Seni',
              controller: _nameCtrl,
              hint: 'Contoh: Sandiwara Dharma Kudeta',
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori Seni',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c['slug'], child: Text(c['name']!)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 24),

            // Basecamp & Wilayah
            const Text(
              '2. Lokasi Markas / Basecamp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: InputDecoration(
                labelText: 'Kabupaten / Kota',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _cities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCity = val);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Kecamatan Markas',
              controller: _districtCtrl,
              hint: 'Contoh: Kandanghaur',
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Alamat Lengkap Basecamp',
              controller: _addressCtrl,
              maxLines: 2,
              hint: 'Alamat lengkap tempat latihan/markas grup',
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            // Rekening Pencairan DP
            const Text(
              '3. Rekening Pencairan Payout DP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedBank,
              decoration: InputDecoration(
                labelText: 'Nama Bank',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBank = val);
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Nomor Rekening',
              controller: _bankNoCtrl,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 1234567890',
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Nama Pemilik Rekening (Sesuai Buku Tabungan)',
              controller: _bankOwnerCtrl,
              hint: 'Contoh: H. Waryono',
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            // Verifikasi KTP
            const Text(
              '4. Dokumen KTP Pimpinan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _handleSimulateUploadKtp,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isKtpUploaded ? Colors.green : Colors.grey.shade400,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _isKtpUploaded ? Colors.green.shade50 : Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Icon(
                      _isKtpUploaded ? Icons.check_circle : Icons.upload_file,
                      color: _isKtpUploaded ? Colors.green : AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isKtpUploaded ? 'Foto KTP Pimpinan Terunggah' : 'Unggah Foto KTP Pimpinan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _isKtpUploaded ? Colors.green.shade800 : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _isKtpUploaded ? 'Klik untuk mengganti dokumen' : 'Format JPG/PNG, teks NIK harus terbaca jelas',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              label: 'Kirim Pengajuan Lapak Seni',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
