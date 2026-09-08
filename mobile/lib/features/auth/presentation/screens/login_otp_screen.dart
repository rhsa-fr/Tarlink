import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
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
  final _loginIdentityCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _obscureLoginPwd = true;
  bool _rememberMe = true;

  // Register fields
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _obscureRegPwd = true;
  bool _obscureRegConfirm = true;

  bool _isLoading = false;

  @override
  void dispose() {
    _loginIdentityCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identity = _loginIdentityCtrl.text.trim();
    final password = _loginPasswordCtrl.text;

    if (identity.isEmpty) {
      _showError('Masukkan nomor WhatsApp atau email');
      return;
    }
    if (password.isEmpty) {
      _showError('Kata sandi tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      await repo.signInWithEmail(identity, password);
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ─── Hero Header ───
              _buildHeroHeader(),

              // ─── Masuk / Daftar Tab Bar ───
              _buildTabBar(),

              // ─── Form Card ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isLoginMode ? _buildLoginCard() : _buildRegisterCard(),
                ),
              ),

              // ─── Divider "ATAU MASUK LEBIH CEPAT DENGAN" ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.outlineVariant.withAlpha(120))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ATAU MASUK LEBIH CEPAT DENGAN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.outlineVariant.withAlpha(120))),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ─── Google Sign-In ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEA4335)),
                        alignment: Alignment.center,
                        child: Text('G', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Masuk dengan Akun Google',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Belum punya akun? ───
              GestureDetector(
                onTap: () => setState(() => _isLoginMode = !_isLoginMode),
                child: RichText(
                  text: TextSpan(
                    text: _isLoginMode ? 'Belum memiliki akun Tarlink? ' : 'Sudah punya akun? ',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: _isLoginMode ? 'Daftar sekarang' : 'Masuk',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Trust Banner ───
              _buildTrustBanner(),

              // ─── Bottom Feature Bar ───
              _buildBottomFeatureBar(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF8F4), Color(0xFFFFF5EE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const TarlinkLogo(height: 36, showSubtitle: true),
          const SizedBox(height: 14),

          // Badge "PENTAS RESMI PANTURA"
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'PENTAS RESMI PANTURA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Heading Jawa
          Text(
            'Sugeng Rawuh ing Tarlink',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Masuk untuk booking orkes hajatan & kelola jadwal\npanggung seni Cirebon-Indramayu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0A22252A), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isLoginMode = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _isLoginMode ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 18, color: _isLoginMode ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Masuk',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: _isLoginMode ? FontWeight.w700 : FontWeight.w500,
                          color: _isLoginMode ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isLoginMode = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: !_isLoginMode ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, size: 18, color: !_isLoginMode ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Daftar Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: !_isLoginMode ? FontWeight.w700 : FontWeight.w500,
                          color: !_isLoginMode ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      key: const ValueKey('login_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0A22252A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masuk Akun',
                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lanjutkan pesanan panggung & musisi Anda',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: AppColors.primary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Identity Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nomor WhatsApp atau Email', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text('Wajib aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginIdentityCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Contoh: 081234567890 atau nama@email',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.contact_phone_outlined, color: AppColors.primary, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFFDF8F4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),

          // Password Field
          Text('Kata Sandi', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _obscureLoginPwd,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureLoginPwd ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
                onPressed: () => setState(() => _obscureLoginPwd = !_obscureLoginPwd),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: const Color(0xFFFDF8F4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.outlineVariant)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 10),

          // Remember + Forgot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('Ingat saya', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                child: Text(
                  'Lupa kata sandi?',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Masuk ke Akun', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      key: const ValueKey('register_card'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x0A22252A), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftar Akun Baru', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Bergabung sebagai pelanggan Tarlink', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.person_add, color: AppColors.primary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 18),

          AppTextField(label: 'Nama Lengkap', controller: _regNameCtrl, keyboardType: TextInputType.name, hint: 'Nama lengkap Anda', prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary)),
          const SizedBox(height: 12),
          AppTextField(label: 'Email Aktif', controller: _regEmailCtrl, keyboardType: TextInputType.emailAddress, hint: 'nama@email.com', prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary)),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Kata Sandi',
            controller: _regPasswordCtrl,
            obscureText: _obscureRegPwd,
            hint: 'Minimal 6 karakter',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(_obscureRegPwd ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
              onPressed: () => setState(() => _obscureRegPwd = !_obscureRegPwd),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Konfirmasi Sandi',
            controller: _regConfirmCtrl,
            obscureText: _obscureRegConfirm,
            hint: 'Ulangi kata sandi',
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(_obscureRegConfirm ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
              onPressed: () => setState(() => _obscureRegConfirm = !_obscureRegConfirm),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Daftar Akun', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EDE8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Transaksi Aman & Terverifikasi',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.tertiary, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jaminan keamanan dana via Rekber Tarlink Escrow bersama Paguyuban Musik Tarling Cirebon-Indramayu.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomFeatureBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _featureItem(Icons.mic, 'SINDEN\nPILIHAN'),
          _featureItem(Icons.speaker_group, 'SOUND 10K -\n25KW'),
          _featureItem(Icons.shield_outlined, 'IZIN POLSEK\nSIAP'),
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted, height: 1.3),
        ),
      ],
    );
  }
}
