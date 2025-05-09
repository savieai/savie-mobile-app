import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:either_dart/either.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/domain.dart';
import '../infrastructure.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._loggingService);

  final LoggingService _loggingService;

  @override
  Future<Either<String, void>> requestOtp({
    required String email,
  }) async {
    _loggingService.addLog(const InfoLog(info: 'Requesting OTP'));
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
      );
      _loggingService.addLog(const InfoLog(info: 'OTP Success'));
      return const Right<String, void>(null);
    } on AuthException catch (e, s) {
      _loggingService.addLog(
        ErrorLog(
          message: 'OTP Failure',
          error: e,
          stackTrace: s,
        ),
      );
      return Left<String, void>(e.message);
    }
  }

  @override
  Future<bool> signInWithEmail({
    required String email,
    required String otp,
  }) async {
    _loggingService.addLog(const InfoLog(info: 'Signing in with email'));
    try {
      await Supabase.instance.client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      _loggingService.addLog(const InfoLog(info: 'Sign in with email Success'));
      return getAuthStatus();
    } catch (e, s) {
      _loggingService.addLog(
        ErrorLog(
          message: 'Sign in with email Failure',
          error: e,
          stackTrace: s,
        ),
      );
      return false;
    }
  }

  @override
  Future<bool> signInWithApple() async {
    _loggingService.addLog(const InfoLog(info: 'Signing in with Apple'));
    try {
      final String rawNonce = Supabase.instance.client.auth.generateRawNonce();
      final String hashedNonce =
          sha256.convert(utf8.encode(rawNonce)).toString();

      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
        ],
        nonce: hashedNonce,
      );

      final String? idToken = credential.identityToken;
      if (idToken == null) {
        return false;
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      _loggingService
          .addLog(const InfoLog(info: 'Signing in with Apple Success'));
      return getAuthStatus();
    } catch (e, s) {
      _loggingService.addLog(
        ErrorLog(
          message: 'Signing in with Apple Failure',
          error: e,
          stackTrace: s,
        ),
      );
      return false;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    _loggingService.addLog(const InfoLog(info: 'Signing in with Google'));
    try {
      const String iosClientId =
          '256363804943-pj14l9af8j4p07n5mqluhor3khmggm3t.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(clientId: iosClientId);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return false;
      }

      Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      _loggingService
          .addLog(const InfoLog(info: 'Signing in with Google Success'));
      return getAuthStatus();
    } catch (e, s) {
      _loggingService.addLog(
        ErrorLog(
          message: 'Signing in with Google Failure',
          error: e,
          stackTrace: s,
        ),
      );
      return false;
    }
  }

  @override
  Stream<bool> watchAuthStatus() =>
      Supabase.instance.client.auth.onAuthStateChange.map(
        (AuthState state) => state.session != null,
      );

  @override
  bool getAuthStatus() => Supabase.instance.client.auth.currentSession != null;

  @override
  Future<void> logout() => Supabase.instance.client.auth.signOut();

  @override
  Future<bool> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return getAuthStatus();
  }
}
