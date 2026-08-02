import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/injection/injection_container.dart';

class FcmHelper {
  /// Last token Firebase handed us. Registration is a network round-trip, so
  /// caching keeps sign-in from paying for it again, and [onTokenRefresh] keeps
  /// the cache honest when Firebase rotates it.
  static String? _cachedToken;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Firebase rotates tokens (reinstall, restore, cache clear). Without this
      // the cached copy goes stale and the next sign-in re-registers a token
      // that no longer routes anywhere.
      messaging.onTokenRefresh.listen(
        (token) => _cachedToken = token.isEmpty ? null : token,
        onError: (e) => debugPrint('FCM token refresh error: $e'),
      );
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  /// The device's push token, or **null** when this device cannot register one.
  ///
  /// Null is a real answer, not a failure to handle: an Android device without
  /// Google Play Services (Huawei, most notably) can never obtain an FCM token,
  /// and registration also fails transiently when the network is down.
  ///
  /// It used to return the literal `'test_fcm_token'` in that case. That is
  /// worse than sending nothing: the backend stores it as a genuine token, so
  /// every push to that user is attempted against an address that cannot exist
  /// — and because the string is a constant, *every* device that fails
  /// registers the same one, so those users collide on a single push identity.
  /// Callers now omit the field instead; see [UserSignupRequest.toJson].
  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;

    // Two attempts: registration fails transiently on a flaky network, and a
    // single retry costs nothing on the device where it genuinely cannot work
    // (that one fails fast and locally, without a round-trip).
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          _cachedToken = token;
          return token;
        }
      } catch (e) {
        debugPrint('Error getting FCM token (attempt ${attempt + 1}): $e');
      }
    }

    debugPrint('FCM token unavailable on this device — push notifications are off.');
    return null;
  }

  /// Non-null value for the `fcmToken` field the auth endpoints require.
  ///
  /// The real token whenever the device has one. When it does not, a stand-in
  /// that is **unique to this install**.
  ///
  /// This exists only because `/auth/user/signup` and `/auth/user/signin`
  /// reject a request without the field (`400 — رمز FCM مطلوب`). Given that,
  /// the choice is not between a fake token and no token, it is between a fake
  /// token that is unique and one that is shared. The previous constant
  /// `'test_fcm_token'` was shared: every device that failed registration
  /// claimed the same push identity, so if the backend keys devices by token
  /// those users overwrite each other's row and a push meant for one can reach
  /// another.
  ///
  /// The stand-in is prefixed so it is obvious in the database and can be
  /// swept: a real FCM token never begins with `no-fcm-`.
  ///
  /// **The proper fix is on the backend** — make `fcmToken` optional, or accept
  /// null, so devices without Play Services simply register no push address.
  static Future<String> tokenForAuthRequest() async {
    final String? real = await getToken();
    if (real != null) return real;

    final AppCache cache = getIt<AppCache>();
    final String? existing = cache.getDeviceFallbackId();
    if (existing != null && existing.isNotEmpty) return existing;

    // Generated once and kept: the same device must present the same identity
    // on every sign-in, or the backend accumulates a new bogus device row each
    // time the user logs in.
    final String generated = 'no-fcm-${const Uuid().v4()}';
    await cache.saveDeviceFallbackId(generated);
    return generated;
  }
}
