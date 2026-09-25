import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/network/auth_session.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell_screen.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/presentation/screens/login_otp_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthSession.authState,
      builder: (context, user, _) {
        if (user == null) {
          return const LoginOtpScreen();
        }
        return const MainShellScreen();
      },
    );
  }
}

