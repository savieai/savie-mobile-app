import 'package:either_dart/either.dart';

abstract class AuthRepository {
  Future<Either<String, void>> requestOtp({
    required String email,
  });
  Future<bool> signInWithEmail({
    required String email,
    required String otp,
  });
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  });
  Future<bool> signInWithGoogle();
  Future<bool> signInWithApple();
  Stream<bool> watchAuthStatus();
  bool getAuthStatus();
  Future<void> logout();
}
