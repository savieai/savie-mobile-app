abstract class AuthRepository {
  Future<bool> signInWithGoogle();
  Future<bool> signInWithApple();
  Stream<bool> watchAuthStatus();
  bool getAuthStatus();
  Future<void> logout();
}
