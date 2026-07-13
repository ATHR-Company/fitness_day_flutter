/// Holds the app's active language code so the [TokenInterceptor] can always
/// read the live value without depending on a hardcoded storage key.
///
/// Call [AppLocale.set] whenever the locale changes (e.g. inside the language
/// dialog's onSave callback). The interceptor reads [AppLocale.langCode] on
/// every request, so it is always up to date.
class AppLocale {
  AppLocale._();

  static String _langCode = 'ar'; // default

  /// The current language code ('ar' or 'en').
  static String get langCode => _langCode;

  /// Call this after [context.setLocale] to keep the interceptor in sync.
  static void set(String languageCode) {
    _langCode = languageCode;
  }
}
