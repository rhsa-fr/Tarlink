import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/main_shell_screen.dart';
import '../../../../core/widgets/tarlink_logo.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'email_otp_verification_screen.dart';
import 'forgot_password_screen.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  bool _isLoginMode = true;

  // Login fields
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Register fields
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      _showError('Masukkan alamat email yang valid');
      return;
    }
    if (password.isEmpty) {
      _showError('Password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      await repo.signInWithEmail(email, password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Masuk gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final password = _regPasswordCtrl.text;
    final confirm = _regConfirmCtrl.text;

    if (name.isEmpty) { _showError('Nama lengkap harus diisi'); return; }
    if (email.isEmpty || !email.contains('@')) { _showError('Email tidak valid'); return; }
    if (password.length < 6) { _showError('Password minimal 6 karakter'); return; }
    if (password != confirm) { _showError('Konfirmasi password tidak cocok'); return; }

    setState(() => _isLoading = true);
    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      await repo.signUpWithEmail(email, password, name);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EmailOtpVerificationScreen(email: email)),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Pendaftaran gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      await repo.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Masuk dengan Google: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo
              const Center(
                child: TarlinkLogo(height: 40, showSubtitle: true),
              ),
              const SizedBox(height: 20),

              // Heading
              Text(
                _isLoginMode ? 'Selamat Datang' : 'Buat Akun Baru',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isLoginMode
                    ? 'Masuk ke akun Tarlink Anda'
                    : 'Bergabung sebagai pelanggan Tarlink',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Segmented Toggle: Masuk / Daftar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginMode = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLoginMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isLoginMode
                                ? const [BoxShadow(color: Color(0x0C22252A), blurRadius: 4, offset: Offset(0, 1))]
                                : null,
                          ),
                          child: Text(
                            'Masuk',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: _isLoginMode ? FontWeight.w700 : FontWeight.w500,
                              color: _isLoginMode ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLoginMode = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLoginMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isLoginMode
                                ? const [BoxShadow(color: Color(0x0C22252A), blurRadius: 4, offset: Offset(0, 1))]
                                : null,
                          ),
                          child: Text(
                            'Daftar',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: !_isLoginMode ? FontWeight.w700 : FontWeight.w500,
                              color: !_isLoginMode ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
              ),

              const SizedBox(height: 20),

              // Divider "ATAU"
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ATAU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 20),

              // Google Sign-In
              OutlinedButton(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.outlineVariant, width: 1.5),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEA4335),
                      ),
                      alignment: Alignment.center,
                      child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lanjutkan dengan Google',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info Pendaftaran Lapak Grup
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pimpinan grup kesenian dapat mengajukan pendaftaran lapak setelah masuk melalui menu "Lapak Grup".',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF5D4037),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Alamat Email',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          hint: 'nama@email.com',
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Kata Sandi',
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          hint: 'Masukkan kata sandi',
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
            },
            child: Text(
              'Lupa Password?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AppButton(
          label: 'Masuk',
          isLoading: _isLoading,
          onPressed: _handleEmailLogin,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Nama Lengkap',
          controller: _regNameCtrl,
          keyboardType: TextInputType.name,
          hint: 'Nama lengkap Anda',
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Email',
          controller: _regEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          hint: 'nama@email.com',
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Password',
          controller: _regPasswordCtrl,
          obscureText: _obscureRegPassword,
          hint: 'Minimal 6 karakter',
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Konfirmasi Password',
          controller: _regConfirmCtrl,
          obscureText: _obscureRegConfirm,
          hint: 'Ulangi password',
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRegConfirm ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textMuted,
            ),
            onPressed: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Daftar Akun',
          isLoading: _isLoading,
          onPressed: _handleRegister,
        ),
      ],
    );
  }
}
