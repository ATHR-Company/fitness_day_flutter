import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime / build-time secrets.
///
/// `.env` is gitignored — each developer supplies their own copy.
///
/// IMPORTANT (security): every path here embeds the key in the build. Anyone
/// can decompile the app and extract it. Keep this for development; move these
/// secrets behind your own backend before releasing to real users.
class AppEnv {
  AppEnv._();

  // ─── OpenRouter (used by AI chat + meal scan) ────────────────────────────
  //
  // Resolved at runtime from the bundled `.env` first, falling back to a
  // compile-time --dart-define. Reading `.env` at runtime is what lets a plain
  // `flutter run` / IDE debug work without --dart-define-from-file.
  static String get openRouterApiKey {
    final fromFile =
        dotenv.isInitialized ? (dotenv.env['OPENROUTER_API_KEY'] ?? '') : '';
    if (fromFile.isNotEmpty) return fromFile;
    return const String.fromEnvironment('OPENROUTER_API_KEY');
  }

  // ─── Firebase ────────────────────────────────────────────────────────────
  //
  // These feed `const FirebaseOptions(...)` in firebase_options.dart, which
  // must be compile-time constants, so they stay on --dart-define and cannot
  // be read from `.env` at runtime. Pass them with
  // `--dart-define-from-file=.env` (see .vscode/launch.json) or omit them and
  // rely on the native google-services.json / GoogleService-Info.plist.
  static const String firebaseWebApiKey =
      String.fromEnvironment('FIREBASE_WEB_API_KEY');

  static const String firebaseAndroidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');

  static const String firebaseIosApiKey =
      String.fromEnvironment('FIREBASE_IOS_API_KEY');
}
