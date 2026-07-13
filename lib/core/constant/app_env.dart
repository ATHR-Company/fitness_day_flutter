/// Reads compile-time environment variables injected via --dart-define.
///
/// HOW TO RUN:
///   flutter run \
///     --dart-define=OPENROUTER_API_KEY=sk-or-v1-xxx \
///     --dart-define=FIREBASE_WEB_API_KEY=AIza... \
///     --dart-define=FIREBASE_ANDROID_API_KEY=AIza... \
///     --dart-define=FIREBASE_IOS_API_KEY=AIza...
///
/// Or create a launch.json in .vscode with "toolArgs" containing the defines,
/// or pass them via a dart_defines file:
///   flutter run --dart-define-from-file=.env
///
/// IMPORTANT: Never hardcode secrets in Dart source files.
/// The .env file is listed in .gitignore and must never be committed.
class AppEnv {
  AppEnv._();

  // ─── OpenRouter ──────────────────────────────────────────────────────────
  static const String openRouterApiKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  // ─── Firebase ────────────────────────────────────────────────────────────
  static const String firebaseWebApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: '',
  );

  static const String firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
    defaultValue: '',
  );

  static const String firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
    defaultValue: '',
  );
}
