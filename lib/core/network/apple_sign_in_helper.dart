import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_day/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// An Apple sign-in attempt that failed, carrying a message that can be shown
/// to the user as-is. The raw platform error is kept in [code]/[details] for
/// logs only.
class AppleSignInFailure implements Exception {
  final String message;
  final String? code;
  final Object? details;

  const AppleSignInFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'AppleSignInFailure($code): $message';
}

/// The result of a successful Apple sign-in.
///
/// Apple only returns the user's name on the **very first** authorization for
/// a given Apple ID + app pair. Every later sign-in returns `null` for both
/// name fields, so [fullName] is captured here and mirrored onto the Firebase
/// user the one time it is available.
class AppleSignInResult {
  /// Firebase ID token (`iss: securetoken.google.com`) — the token the backend
  /// expects on `POST /auth/social`.
  final String idToken;

  /// `"Given Family"`, or `null` when Apple did not supply a name (any
  /// sign-in after the first one).
  final String? fullName;

  /// Apple relay or real email, `null` after the first sign-in.
  final String? email;

  const AppleSignInResult({required this.idToken, this.fullName, this.email});
}

class AppleSignInHelper {
  /// Characters Apple accepts inside a nonce.
  static const String _nonceCharset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';

  /// Returns the sign-in result, or `null` when the user canceled the flow.
  /// Throws [AppleSignInFailure] on a real error.
  static Future<AppleSignInResult?> signIn() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        throw AppleSignInFailure(LocaleKeys.login_apple_not_available.tr());
      }

      // Replay protection: Apple signs the SHA-256 of the nonce into the
      // identity token, and Firebase re-hashes `rawNonce` to verify the token
      // was minted for *this* request. Skipping it lets a stolen identity
      // token be replayed against the backend.
      final String rawNonce = _generateNonce();
      final String hashedNonce = _sha256(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final String? identityToken = appleCredential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw AppleSignInFailure(LocaleKeys.login_apple_error_invalid.tr());
      }

      // ── Sign in to Firebase using the Apple credential ───────────────
      final credential = OAuthProvider('apple.com').credential(
        idToken: identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AppleSignInFailure(LocaleKeys.login_apple_error_generic.tr());
      }

      final String? fullName = _joinName(
        appleCredential.givenName,
        appleCredential.familyName,
      );

      // First-authorization only: Firebase creates the Apple user without a
      // display name, so persist the name while Apple is still handing it out.
      final String? existingName = firebaseUser.displayName;
      bool nameUpdated = false;
      if (fullName != null && (existingName == null || existingName.isEmpty)) {
        try {
          await firebaseUser.updateDisplayName(fullName);
          nameUpdated = true;
        } catch (e) {
          // Cosmetic only — never fail the sign-in over it.
          debugPrint('[AppleSignIn] ⚠️ could not persist display name: $e');
        }
      }

      // The ID token minted at sign-in predates the display-name write, so it
      // still carries no `name` claim. Force a refresh so the backend sees it.
      final String? token = await firebaseUser.getIdToken(nameUpdated);
      if (token == null || token.isEmpty) {
        throw AppleSignInFailure(LocaleKeys.login_apple_error_generic.tr());
      }

      return AppleSignInResult(
        idToken: token,
        fullName: fullName ?? existingName,
        email: appleCredential.email ?? firebaseUser.email,
      );
    } on AppleSignInFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('[AppleSignIn] ❌ authorization ${e.code} — ${e.message}');

      // Backing out of the Apple sheet is not an error.
      if (e.code == AuthorizationErrorCode.canceled) return null;

      switch (e.code) {
        case AuthorizationErrorCode.failed:
          throw AppleSignInFailure(
            LocaleKeys.login_apple_error_failed.tr(),
            code: e.code.name,
            details: e.message,
          );
        case AuthorizationErrorCode.invalidResponse:
          throw AppleSignInFailure(
            LocaleKeys.login_apple_error_invalid.tr(),
            code: e.code.name,
            details: e.message,
          );
        case AuthorizationErrorCode.notHandled:
        case AuthorizationErrorCode.notInteractive:
          throw AppleSignInFailure(
            LocaleKeys.login_apple_error_not_handled.tr(),
            code: e.code.name,
            details: e.message,
          );
        case AuthorizationErrorCode.unknown:
        default:
          throw AppleSignInFailure(
            LocaleKeys.login_apple_error_generic.tr(),
            code: e.code.name,
            details: e.message,
          );
      }
    } on SignInWithAppleNotSupportedException catch (e) {
      debugPrint('[AppleSignIn] ❌ not supported — ${e.message}');
      throw AppleSignInFailure(LocaleKeys.login_apple_not_available.tr());
    } on SignInWithAppleException catch (e) {
      debugPrint('[AppleSignIn] ❌ $e');
      throw AppleSignInFailure(LocaleKeys.login_apple_error_generic.tr());
    } on FirebaseAuthException catch (e) {
      debugPrint('[AppleSignIn] ❌ firebase ${e.code} — ${e.message}');
      throw _mapFirebaseException(e);
    } catch (e) {
      debugPrint('[AppleSignIn] ❌ unexpected $e');
      throw AppleSignInFailure(LocaleKeys.login_apple_error_generic.tr());
    }
  }

  /// Signs the Firebase session out so the next Apple sign-in starts clean.
  /// The native Apple sheet keeps no session of its own, so there is nothing
  /// else to revoke here.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('[AppleSignIn] ⚠️ signOut failed: $e');
    }
  }

  /// `true` when the signed-in Firebase user authenticated through Apple.
  static bool get isAppleUser =>
      FirebaseAuth.instance.currentUser?.providerData.any(
        (p) => p.providerId == 'apple.com',
      ) ??
      false;

  /// Revokes the app's Apple token on account deletion.
  ///
  /// App Review guideline 5.1.1(v) requires an app that offers Sign in with
  /// Apple to revoke the token when the account is deleted — otherwise the
  /// Apple ID keeps listing the app under "Apps Using Apple ID" forever.
  ///
  /// The authorization code Apple hands out is single-use and expires in
  /// minutes, so the one captured at sign-in is useless here: the user has to
  /// re-authorize to mint a fresh one.
  ///
  /// Returns `true` when the token was revoked. Best-effort by design — a
  /// failure is logged and reported, never thrown, so it cannot block the
  /// backend account deletion the user asked for.
  static Future<bool> revokeAppleToken() async {
    if (!isAppleUser) return false;

    try {
      final String rawNonce = _generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        nonce: _sha256(rawNonce),
      );

      final String authorizationCode = appleCredential.authorizationCode;
      if (authorizationCode.isEmpty) {
        debugPrint('[AppleSignIn] ⚠️ revoke: empty authorizationCode');
        return false;
      }

      // Firebase rejects a revoke on a stale session, so re-authenticate with
      // the credential just minted before spending the code.
      final String? identityToken = appleCredential.identityToken;
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null && identityToken != null && identityToken.isNotEmpty) {
        await user.reauthenticateWithCredential(
          OAuthProvider('apple.com').credential(
            idToken: identityToken,
            rawNonce: rawNonce,
            accessToken: authorizationCode,
          ),
        );
      }

      await FirebaseAuth.instance.revokeTokenWithAuthorizationCode(
        authorizationCode,
      );
      debugPrint('[AppleSignIn] ✅ Apple token revoked');
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      // User dismissed the re-authorization sheet.
      debugPrint('[AppleSignIn] ⚠️ revoke aborted: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('[AppleSignIn] ⚠️ revoke failed: $e');
      return false;
    }
  }

  static AppleSignInFailure _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_network.tr(),
          code: e.code,
          details: e.message,
        );
      case 'account-exists-with-different-credential':
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_account_exists.tr(),
          code: e.code,
          details: e.message,
        );
      case 'invalid-credential':
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_invalid_credential.tr(),
          code: e.code,
          details: e.message,
        );
      case 'operation-not-allowed':
        // Apple provider is off in Firebase Console → Authentication, or the
        // Services ID / key pair there does not match the app.
        debugPrint(
          '[AppleSignIn] ⚠️ operation-not-allowed: enable the Apple provider '
          'in Firebase Console → Authentication → Sign-in method, and fill in '
          'the Services ID, Apple Team ID, Key ID and .p8 private key.',
        );
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_disabled.tr(),
          code: e.code,
          details: e.message,
        );
      case 'user-disabled':
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_user_disabled.tr(),
          code: e.code,
          details: e.message,
        );
      default:
        return AppleSignInFailure(
          LocaleKeys.login_apple_error_generic.tr(),
          code: e.code,
          details: e.message,
        );
    }
  }

  static String? _joinName(String? given, String? family) {
    final parts = [
      given,
      family,
    ].whereType<String>().map((p) => p.trim()).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static String _generateNonce([int length = 32]) {
    final random = Random.secure();
    return List.generate(
      length,
      (_) => _nonceCharset[random.nextInt(_nonceCharset.length)],
    ).join();
  }

  static String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
