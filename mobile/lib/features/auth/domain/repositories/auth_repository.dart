import '../../../auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> signInWithPhoneOtp(String phone);
  Future<UserModel> verifyPhoneOtp(String phone, String token);
  Future<void> signInWithGoogle();
  Future<void> signUpWithEmail(String email, String password, String name);
  Future<void> signInWithEmail(String email, String password);
  Future<UserModel> verifyEmailOtp(String email, String token);
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> authStateChanges();
}
