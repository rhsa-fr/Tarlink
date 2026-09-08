import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/tarlink_logo.dart';
import '../../data/repositories/auth_repository_impl.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan alamat email yang valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = AuthRepositoryImpl(SupabaseService.client);
      await repo.resetPassword(email);
      if (mounted) {
        setState(() => _isSent = true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim link reset: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Lupa Password',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Center(
                child: TarlinkLogo(height: 36, showSubtitle: true),
              ),
              const SizedBox(height: 32),

              if (_isSent) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.mark_email_read_outlined, size: 52, color: Colors.green.shade700),
                      const SizedBox(height: 14),
                      Text(
                        'Link Reset Terkirim!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan periksa kotak masuk atau folder spam email ${_emailCtrl.text.trim()} untuk instruksi penggantian password.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.green.shade800,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Kembali ke Masuk',
                  onPressed: () => Navigator.pop(context),
                ),
              ] else ...[
                Text(
                  'Atur Ulang Kata Sandi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email akun Anda. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                AppTextField(
                  label: 'Email Terdaftar',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'nama@email.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: 'Kirim Tautan Reset',
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
