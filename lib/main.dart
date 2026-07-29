import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/fitness_day.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/core/network/fcm_helper.dart';
import 'package:fitness_day/core/notification_helper/local_notification.dart';
import 'package:fitness_day/core/services/socket_service.dart';
import 'package:fitness_day/core/routes/app_router.dart';
import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load runtime secrets from the bundled .env. Wrapped so a missing/empty
  // file never crashes startup — AppEnv still falls back to --dart-define.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await FcmHelper.initialize();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await LocalNotification(navigatorKey: AppRouter.navigatorKey).initialize();
  await EasyLocalization.ensureInitialized();
  // Seed AppLocale with the locale the user previously saved.
  final prefs = await SharedPreferences.getInstance();
  final savedLocaleStr = prefs.getString('locale');
  String initialLang = 'en'; // default to en as defined in startLocale
  if (savedLocaleStr != null && savedLocaleStr.contains('ar')) {
    initialLang = 'ar';
  } else if (savedLocaleStr != null && savedLocaleStr.contains('en')) {
    initialLang = 'en';
  }
  AppLocale.set(initialLang);
  await di.init();

  // Connect Socket.IO on startup if user token exists
  _initSocketIfLoggedIn();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'), // Set default to English
      child: const FitnessDay(),
    ),
  );
}

/// Connects Socket.IO at app launch if an access token is stored. Sign-in and
/// sign-out handle the connection from then on.
Future<void> _initSocketIfLoggedIn() async {
  try {
    await di.getIt<SocketService>().connectWithStoredToken();
  } catch (_) {}
}
