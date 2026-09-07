import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> signInWithPhoneOtp(String phone);
  Future<UserModel> verifyPhoneOtp(String phone, String token);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> authStateChanges();
}
