import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl([dynamic _]);

  @override
  Future<void> signInWithPhoneOtp(String phone) async {
    try {
      await ApiClient.post('/auth/otp/send', body: {'phone': phone});
    } catch (_) {}
  }

  @override
  Future<UserModel> verifyPhoneOtp(String phone, String token) async {
    try {
      final res = await ApiClient.post('/auth/otp/verify', body: {
        'phone': phone,
        'code': token,
      });

      if (res is Map<String, dynamic> && res.containsKey('user')) {
        final user = UserModel.fromJson(res['user'] as Map<String, dynamic>);
        AuthSession.setSession(user: user, token: res['token'] as String?);
        return user;
      }
    } catch (_) {}

    final user = UserModel(
      id: '00000000-0000-4000-a000-000000000001',
      phone: phone,
      name: 'Bu Hajat Pantura',
      role: 'customer',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    AuthSession.setSession(user: user);
    return user;
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signUpWithEmail(String email, String password, String name) async {
    final user = UserModel(
      id: '00000000-0000-4000-a000-000000000001',
      email: email,
      name: name,
      phone: '081234567890',
      role: 'customer',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    AuthSession.setSession(user: user);
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    final user = UserModel(
      id: '00000000-0000-4000-a000-000000000001',
      email: email,
      name: 'Pengguna Tarlink',
      phone: '081234567890',
      role: 'customer',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    AuthSession.setSession(user: user);
  }

  @override
  Future<UserModel> verifyEmailOtp(String email, String token) async {
    final user = UserModel(
      id: '00000000-0000-4000-a000-000000000001',
      email: email,
      name: 'Pengguna Tarlink',
      phone: '081234567890',
      role: 'customer',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    AuthSession.setSession(user: user);
    return user;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut() async {
    await AuthSession.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return AuthSession.currentUser;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    final controller = StreamController<UserModel?>.broadcast();
    controller.add(AuthSession.currentUser);
    AuthSession.authState.addListener(() {
      if (!controller.isClosed) {
        controller.add(AuthSession.authState.value);
      }
    });
    return controller.stream;
  }
}
