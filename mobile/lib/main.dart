import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell_screen.dart';
import 'features/auth/presentation/screens/login_otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);
  await SupabaseService.initialize();
  runApp(const ProviderScope(child: TarlingBookApp()));
}

class TarlingBookApp extends StatelessWidget {
  const TarlingBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarlink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSub;
  bool _isLoading = true;
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = SupabaseService.client.auth.currentSession;
    _isLoading = false;

    _authSub = SupabaseService.client.auth.onAuthStateChange.listen((event) {
      if (!mounted) return;
      setState(() {
        _session = event.session;
      });
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_session == null) {
      return const LoginOtpScreen();
    }

    return const MainShellScreen();
  }
}
