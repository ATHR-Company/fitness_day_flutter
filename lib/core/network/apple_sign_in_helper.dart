import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// An Apple sign-in attempt that failed, carrying a message that can be shown
/// to the user as-is.
class AppleSignInFailure implements Exception {
  final String message;
  final String? code;
  final Object? details;

  const AppleSignInFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'AppleSignInFailure($code): $message';
}

class AppleSignInHelper {
  /// Returns the Firebase ID token, or `null` when the user canceled the
  /// sign-in flow. Throws [AppleSignInFailure] on a real error.
  static Future<String?> signIn() async {
    try {
      // Check if Apple Sign In is available on this device
      if (!await SignInWithApple.isAvailable()) {
        throw AppleSignInFailure('login.apple_not_available'.tr());
      }

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw AppleSignInFailure('login.apple_error_generic'.tr());
      }

      // Retrieve the Firebase ID Token
      return await firebaseUser.getIdToken();
    } on AppleSignInFailure {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('[AppleSignIn] ❌ Authorization error: ${e.code} — ${e.message}');
      
      // User canceled the sign-in flow
      if (e.code == AuthorizationErrorCode.canceled) {
        return null;
      }
      
      // Map specific error codes to user-friendly messages
      switch (e.code) {
        case AuthorizationErrorCode.failed:
          throw AppleSignInFailure('login.apple_error_failed'.tr(), code: e.code.toString());
        case AuthorizationErrorCode.invalidResponse:
          throw AppleSignInFailure('login.apple_error_invalid'.tr(), code: e.code.toString());
        case AuthorizationErrorCode.notHandled:
          throw AppleSignInFailure('login.apple_error_not_handled'.tr(), code: e.code.toString());
        case AuthorizationErrorCode.unknown:
        default:
          throw AppleSignInFailure('login.apple_error_generic'.tr(), code: e.code.toString());
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[AppleSignIn] ❌ Firebase error: ${e.code} — ${e.message}');
      
      // Map Firebase-specific errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw AppleSignInFailure('login.apple_error_account_exists'.tr(), code: e.code);
        case 'invalid-credential':
          throw AppleSignInFailure('login.apple_error_invalid_credential'.tr(), code: e.code);
        case 'operation-not-allowed':
          throw AppleSignInFailure('login.apple_error_disabled'.tr(), code: e.code);
        case 'user-disabled':
          throw AppleSignInFailure('login.apple_error_user_disabled'.tr(), code: e.code);
        default:
          throw AppleSignInFailure('login.apple_error_generic'.tr(), code: e.code);
      }
    } catch (e) {
      debugPrint('[AppleSignIn] ❌ Unexpected error: $e');
      throw AppleSignInFailure('login.apple_error_generic'.tr());
    }
  }
}
