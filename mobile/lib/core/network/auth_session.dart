import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/models/user_model.dart';
import 'api_client.dart';

/// Centralized Session & User Manager for Tarlink Mobile.
/// Replaces direct Supabase Auth SDK.
class AuthSession {
  AuthSession._();

  static UserModel? _currentUser = UserModel(
    id: '00000000-0000-4000-a000-000000000001',
    name: 'Bu Hajat Pantura',
    phone: '081234567890',
    email: 'hajat@tarlink.id',
    role: 'customer',
    isVerified: true,
    createdAt: DateTime.now(),
  );

  static final ValueNotifier<UserModel?> authState = ValueNotifier(_currentUser);

  static UserModel? get currentUser => _currentUser;
  static String get currentUserId => _currentUser?.id ?? '00000000-0000-4000-a000-000000000001';
  static bool get isLoggedIn => _currentUser != null;

  static void setSession({required UserModel user, String? token}) {
    _currentUser = user;
    if (token != null) {
      ApiClient.setAuthToken(token);
    }
    authState.value = user;
  }

  static Future<void> signOut() async {
    _currentUser = null;
    ApiClient.setAuthToken(null);
    authState.value = null;
  }

  static void updateRole(String role) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      authState.value = _currentUser;
    }
  }
}
