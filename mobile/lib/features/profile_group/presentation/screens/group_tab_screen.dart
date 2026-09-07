import 'package:flutter/material.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/presentation/screens/login_otp_screen.dart';
import '../../../catalog/data/models/artist_profile_model.dart';
import '../../domain/repositories/group_repository.dart';
import 'group_dashboard_screen.dart';
import 'register_stall_screen.dart';

class GroupTabScreen extends StatefulWidget {
  final GroupRepository repository;

  const GroupTabScreen({super.key, required this.repository});

  @override
  State<GroupTabScreen> createState() => _GroupTabScreenState();
}

class _GroupTabScreenState extends State<GroupTabScreen> {
  bool _isLoading = true;
  ArtistProfileModel? _artistProfile;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        // Fallback for preview / demo: use mock artist
        _currentUserId = 'mock-user-1';
        _artistProfile = await widget.repository.getMyArtistProfile('a1');
      } else {
        _currentUserId = user.id;
        _artistProfile = await widget.repository.getMyArtistProfile(user.id);
      }
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 1. Jika sudah disetujui / aktif
    if (_artistProfile != null && _artistProfile!.status == 'verified') {
      return GroupDashboardScreen(
        artistId: _artistProfile!.id,
        artistName: _artistProfile!.displayName,
        repository: widget.repository,
      );
    }

    // 2. Jika pengajuan berstatus PENDING
    if (_artistProfile != null && _artistProfile!.status == 'pending') {
      return Scaffold(
        appBar: AppBar(title: const Text('Status Lapak Seni')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.hourglass_top, size: 50, color: Colors.amber.shade800),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pengajuan Lapak Sedang Ditinjau',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sanggar "${_artistProfile!.displayName}" sedang diperiksa oleh Admin Pasar Pantura.\n\nVerifikasi KTP asli pimpinan membutuhkan waktu maksimal 1x24 jam untuk melindungi keamanan transaksi DP.',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _checkProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Periksa Status Verifikasi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Jika belum punya lapak (Role: Customer murni) -> Layar CTA Ajakan Buka Lapak
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapak Kesenian'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.storefront, size: 44, color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Punya Grup Kesenian Pantura?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Daftarkan Sanggar Sandiwara, Tarling Dangdut, atau Organ Tunggal Anda dan raih pesanan dari seluruh Shohibul Hajat.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            _benefitCard(
              icon: Icons.shield_outlined,
              title: 'Pencairan DP 20% Terjamin',
              description: 'DP online otomatis cair ke rekening pimpinan pada H+2 pasca acara selesai, aman dari pembatalan sepihak.',
            ),
            const SizedBox(height: 14),
            _benefitCard(
              icon: Icons.event_available_outlined,
              title: 'Jadwal & Tarif Mandiri',
              description: 'Atur paket pertunjukan, kalender manggung fullday, dan biaya transport zona secara transparan.',
            ),
            const SizedBox(height: 14),
            _benefitCard(
              icon: Icons.contactless_outlined,
              title: 'Anti-Bocor & Transaksi Resmi',
              description: 'Kontak nomor WhatsApp Anda aman dan hanya terbuka untuk Bu Hajat yang sudah melunasi DP.',
            ),
            const SizedBox(height: 36),

            AppButton(
              label: 'Buka Lapak Seni Sekarang',
              onPressed: () async {
                final userId = _currentUserId ?? 'guest';
                if (userId == 'guest') {
                  final loggedIn = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginOtpScreen()),
                  );
                  if (loggedIn == true) _checkProfile();
                  return;
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterStallScreen(userId: userId),
                  ),
                );
                if (result == true) {
                  _checkProfile();
                }
              },
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Proses pendaftaran gratis. Memerlukan foto KTP pimpinan grup.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
