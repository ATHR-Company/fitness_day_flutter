import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmHelper {
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
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  static Future<String> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
    // Fallback if FCM is not available (e.g. emulators without Play Services)
    return 'test_fcm_token';
  }
}
