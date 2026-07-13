import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/fitness_day.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;
import 'package:fitness_day/core/network/fcm_helper.dart';
import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FcmHelper.initialize();
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
