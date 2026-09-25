import 'package:flutter/material.dart';
import '../../../../core/network/auth_session.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../../booking/presentation/screens/my_bookings_screen.dart';
import '../../../catalog/presentation/screens/favorites_screen.dart';
import '../../../catalog/presentation/screens/review_screen.dart';
import '../../../chat_bot/presentation/screens/faq_screen.dart';
import 'login_otp_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final repo = AuthRepositoryImpl();
      final user = await repo.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          children: [
            // 1. Profile Header Card (Ceremonial Golden Ring)
            _buildProfileHeaderCard(),

            const SizedBox(height: 16),

            // 2. Bento Summary Tiles (3 Columns)
            _buildBentoSummaryTiles(),

            const SizedBox(height: 20),

            // 3. Menu Group: Aktivitas Hajat
            _buildMenuGroup(
              title: 'AKTIVITAS HAJAT',
              items: [
                _menuItem(
                  icon: Icons.theater_comedy,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primaryLight,
                  title: 'Pesanan Saya',
                  subtitle: 'Jadwal manggung & status panggung',
                  trailingBadge: '2 Aktif',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
                  },
                ),
                _menuItem(
                  icon: Icons.favorite,
                  iconColor: AppColors.secondaryDark,
                  iconBg: AppColors.secondaryLight,
                  title: 'Grup Tarling Favorit',
                  subtitle: 'Orkes & sinden tersimpan',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
                  },
                ),
                _menuItem(
                  icon: Icons.rate_review,
                  iconColor: AppColors.tertiary,
                  iconBg: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                  title: 'Ulasan & Testimoni',
                  subtitle: 'Ulasan pagelaran terdahulu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReviewScreen(
                          bookingId: 'demo-booking-1',
                          artistId: 'demo-artist-1',
                          artistName: 'Dian Anic & Anica Nada',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Menu Group: Bantuan & Panduan Adat
            _buildMenuGroup(
              title: 'BANTUAN & PANDUAN',
              items: [
                _menuItem(
                  icon: Icons.help_outline,
                  iconColor: AppColors.primaryDark,
                  iconBg: AppColors.surfaceContainerLow,
                  title: 'Pusat Bantuan & FAQ Hajat',
                  subtitle: 'Izin keramaian desa, rekber, & genset',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen()));
                  },
                ),
                _menuItem(
                  icon: Icons.support_agent,
                  iconColor: AppColors.secondary,
                  iconBg: AppColors.secondaryContainer.withValues(alpha: 0.25),
                  title: 'Asisten Layanan Pantura',
                  subtitle: 'Chat bot & panduan pimpinan grup',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ketuk ikon bot di pojok kanan bawah untuk chat langsung!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 5. Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await AuthSession.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginOtpScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: 0.6),
            Colors.white,
            AppColors.secondaryLight.withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppColors.elevationLevel1,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, size: 14, color: AppColors.secondaryDark),
                    SizedBox(width: 4),
                    Text(
                      'SOHIBUL HAJAT PRIORITAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSecondaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.tertiary),
                    SizedBox(width: 4),
                    Text('Terverifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.tertiary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Golden Ring Avatar
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondaryContainer, AppColors.primaryLight],
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Text(
                    (_user?.fullName.isNotEmpty == true) ? _user!.fullName[0].toUpperCase() : 'B',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _user?.fullName.isNotEmpty == true ? _user!.fullName : 'Sohibul Hajat Pantura',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 13, color: AppColors.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          _user?.phone.isNotEmpty == true ? _user!.phone : '+62 812-****-**88',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.badge, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Peran: ${_user?.role.toUpperCase() ?? 'CUSTOMER'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSummaryTiles() {
    return Row(
      children: [
        _bentoTile(Icons.event_available, '2', 'Pesanan Aktif', AppColors.primary, AppColors.primaryLight, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
        }),
        const SizedBox(width: 10),
        _bentoTile(Icons.favorite, '3', 'Grup Favorit', AppColors.secondaryDark, AppColors.secondaryLight, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
        }),
        const SizedBox(width: 10),
        _bentoTile(Icons.confirmation_number, '1', 'Voucher Hajat', AppColors.tertiary, AppColors.tertiaryContainer.withValues(alpha: 0.25), () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()));
        }),
      ],
    );
  }

  Widget _bentoTile(IconData icon, String count, String label, Color color, Color bg, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppColors.elevationLevel1,
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGroup({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppColors.elevationLevel1,
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (trailingBadge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  trailingBadge,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
