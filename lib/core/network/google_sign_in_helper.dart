import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A Google sign-in attempt that failed, carrying a message that can be shown
/// to the user as-is. The raw platform error is kept in [code]/[details] for
/// logs only — `PlatformException(sign_in_failed, …ApiException: 10)` means
/// nothing to a user.
class GoogleSignInFailure implements Exception {
  final String message;
  final String? code;
  final Object? details;

  const GoogleSignInFailure(this.message, {this.code, this.details});

  @override
  String toString() => 'GoogleSignInFailure($code): $message';
}

class GoogleSignInHelper {
  // Web Client ID (Google Cloud Console → Credentials → OAuth Web Application).
  // Required on Android to get an idToken back.
  static const String _webClientId =
      "308069649363-5qn9ole74gehrr242rnhi9lsvduhrt87.apps.googleusercontent.com";

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: _webClientId,
  );

  /// Returns the Firebase ID token, or `null` when the user dismissed the
  /// Google account picker. Throws [GoogleSignInFailure] on a real error.
  static Future<String?> signIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      // Null means the user backed out of the picker — not an error.
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;

      // ── Sign in to Firebase using Google Credentials ────────────────
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw GoogleSignInFailure('login.google_error_generic'.tr());
      }

      // Retrieve the Firebase ID Token (iss: securetoken.google.com) instead
      // of the raw Google ID Token.
      return await firebaseUser.getIdToken();
    } on GoogleSignInFailure {
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('[GoogleSignIn] ❌ ${e.code} — ${e.message}');
      throw _mapPlatformException(e);
    } on FirebaseAuthException catch (e) {
      debugPrint('[GoogleSignIn] ❌ firebase ${e.code} — ${e.message}');
      throw GoogleSignInFailure('login.google_error_generic'.tr(), code: e.code);
    } catch (e) {
      debugPrint('[GoogleSignIn] ❌ $e');
      throw GoogleSignInFailure('login.google_error_generic'.tr());
    }
  }

  /// Maps the Play-services status code hidden inside the platform message to
  /// something actionable.
  ///
  /// The plugin reports every native failure as `sign_in_failed` and buries the
  /// real reason in the text, e.g.
  /// `com.google.android.gms.common.api.ApiException: 10: `.
  ///   * 10    DEVELOPER_ERROR — the SHA-1 of the certificate this build is
  ///           signed with (or the package name) isn't registered on the
  ///           Firebase project.
  ///   * 12500 SIGN_IN_FAILED — usually the same misconfiguration, or Play
  ///           services missing/outdated on the device.
  ///   * 12501 cancelled by the user.
  ///   * 7     network error.
  static GoogleSignInFailure _mapPlatformException(PlatformException e) {
    final String raw = '${e.code} ${e.message ?? ''}';
    final match = RegExp(r'ApiException:\s*(\d+)').firstMatch(raw);
    final int? status = match != null ? int.tryParse(match.group(1)!) : null;

    if (e.code == 'network_error' || status == 7) {
      return GoogleSignInFailure(
        'login.google_error_network'.tr(),
        code: e.code,
        details: e.message,
      );
    }

    if (status == 10 || status == 12500) {
      // A configuration problem — nothing the user can do about it, so keep
      // the message plain and leave the diagnosis in the log.
      debugPrint(
        '[GoogleSignIn] ⚠️ DEVELOPER_ERROR: the SHA-1 fingerprint of the '
        'certificate this build is signed with is not registered on the '
        'Firebase project (or the package name does not match '
        'google-services.json). Add the fingerprint in Firebase → Project '
        'settings → Android app, then replace android/app/google-services.json.',
      );
      return GoogleSignInFailure(
        'login.google_error_config'.tr(),
        code: e.code,
        details: e.message,
      );
    }

    return GoogleSignInFailure(
      'login.google_error_generic'.tr(),
      code: e.code,
      details: e.message,
    );
  }
}
