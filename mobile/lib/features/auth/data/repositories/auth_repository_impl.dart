import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<void> signInWithPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  @override
  Future<UserModel> verifyPhoneOtp(String phone, String token) async {
    final res = await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );

    final user = res.user;
    if (user == null) {
      throw const AuthException('Verifikasi gagal: User tidak ditemukan');
    }

    // Fetch user profile from public.users table
    final data = await _client
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      return UserModel.fromJson(data);
    }

    // Upsert initial profile if first login
    final newProfile = {
      'id': user.id,
      'phone': phone,
      'name': 'Pengguna Baru',
      'role': 'customer',
      'is_verified': false,
    };
    final inserted = await _client
        .from(SupabaseConstants.tableUsers)
        .upsert(newProfile)
        .select()
        .single();

    return UserModel.fromJson(inserted);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.tarlingbook://login-callback/',
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final currentAuthUser = _client.auth.currentUser;
    if (currentAuthUser == null) return null;

    final data = await _client
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('id', currentAuthUser.id)
        .maybeSingle();

    if (data != null) {
      return UserModel.fromJson(data);
    }

    // Auto-create initial profile for OAuth (Google) users as default role customer
    final fullName = currentAuthUser.userMetadata?['full_name'] as String? ??
        currentAuthUser.userMetadata?['name'] as String? ??
        'Pengguna Pantura';
    final avatar = currentAuthUser.userMetadata?['avatar_url'] as String?;

    final newProfile = {
      'id': currentAuthUser.id,
      'phone': currentAuthUser.phone ?? '',
      'email': currentAuthUser.email,
      'name': fullName,
      'role': 'customer',
      'avatar_url': avatar,
      'is_verified': false,
    };

    final inserted = await _client
        .from(SupabaseConstants.tableUsers)
        .upsert(newProfile)
        .select()
        .single();

    return UserModel.fromJson(inserted);
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return getCurrentUser();
    });
  }
}
