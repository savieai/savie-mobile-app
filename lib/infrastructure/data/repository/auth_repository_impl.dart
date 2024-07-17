import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/domain.dart';

@Singleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<bool> signInWithApple() async {
    final String rawNonce = Supabase.instance.client.auth.generateRawNonce();
    final String hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

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

    return getAuthStatus();
  }

  @override
  Future<bool> signInWithGoogle() async {
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

      return getAuthStatus();
    } catch (_) {
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
}
