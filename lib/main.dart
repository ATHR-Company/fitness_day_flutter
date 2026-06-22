import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/fitness_day.dart';
import 'package:flutter/material.dart';
import 'package:fitness_day/core/injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'), // Set default to Arabic
      child: const FitnessDay(),
    ),
  );
}
