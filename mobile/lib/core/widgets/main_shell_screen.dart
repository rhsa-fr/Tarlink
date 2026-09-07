import 'package:flutter/material.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/presentation/screens/admin_panel_screen.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/booking/presentation/screens/my_bookings_screen.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/presentation/screens/catalog_search_screen.dart';
import '../../features/chat_bot/presentation/widgets/floating_chat_bot.dart';
import '../../features/profile_group/data/repositories/group_repository_impl.dart';
import '../../features/profile_group/presentation/screens/group_tab_screen.dart';
import '../network/supabase_client.dart';
import '../theme/app_colors.dart';

import '../../features/auth/presentation/screens/account_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';

class MainShellScreen extends StatefulWidget {
  /// Jika null, role dicek secara dinamis dari tabel users (role == 'admin').
  final bool? isAdmin;

  const MainShellScreen({super.key, this.isAdmin});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    if (widget.isAdmin != null) {
      setState(() => _isAdmin = widget.isAdmin!);
      return;
    }

    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      final user = await repo.getCurrentUser();
      if (mounted) {
        setState(() {
          _isAdmin = user?.isAdmin ?? false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isAdmin = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = SupabaseService.client;
    final screens = <Widget>[
      HomeScreen(
        onExploreTap: () => setState(() => _currentIndex = 1),
      ),
      CatalogSearchScreen(repository: CatalogRepositoryImpl(client)),
      const MyBookingsScreen(),
      GroupTabScreen(repository: GroupRepositoryImpl(client)),
      if (_isAdmin)
        AdminPanelScreen(repository: AdminRepositoryImpl(client)),
      const AccountScreen(),
    ];

    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return FloatingChatBot(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          indicatorColor: AppColors.primaryLight,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primaryDark),
              label: 'Beranda',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search, color: AppColors.primaryDark),
              label: 'Jelajah',
            ),
            const NavigationDestination(
              icon: Icon(Icons.confirmation_number_outlined),
              selectedIcon: Icon(Icons.confirmation_number, color: AppColors.primaryDark),
              label: 'Pesanan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront, color: AppColors.primaryDark),
              label: 'Lapak Grup',
            ),
            if (_isAdmin)
              const NavigationDestination(
                icon: Icon(Icons.admin_panel_settings_outlined),
                selectedIcon: Icon(Icons.admin_panel_settings, color: AppColors.primaryDark),
                label: 'Panel Pasar',
              ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primaryDark),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}
