/// Links used when sharing the app with friends.
///
/// The only place these are defined — update here, not at the call sites.
class AppShareLinks {
  const AppShareLinks._();

  static const String website = 'https://fitnessday.tech';

  /// What "share the app" sends.
  ///
  /// A single link for both platforms, on our own domain, so it behaves the
  /// same wherever it lands:
  ///   - app installed → the OS claims it as an App Link / Universal Link and
  ///     opens the app on home ([UserAppRoutes.openApp] redirects there)
  ///   - app not installed → the browser opens it, and the **website** is what
  ///     forwards to [androidStore] / [iosStore] by user-agent
  ///
  /// This replaced sending a store URL picked from the *sender's* platform,
  /// which sent Play Store links to iPhone users and never opened the app for
  /// anyone who already had it.
  static const String openApp = '$website/open';

  /// Where `/open` should forward a visitor who does not have the app. Kept
  /// here as the canonical URLs even though the redirect itself is server-side.
  static const String androidStore =
      'https://play.google.com/store/apps/details?id=com.athr.fitnessday';

  /// TODO: replace `id000000000` with the real numeric App Store id once the
  /// app is live on the App Store — it is only known after the first submission.
  static const String iosStore = 'https://apps.apple.com/app/id000000000';

  /// Shareable web link for a product. Kept on the [website] domain so it opens
  /// the app directly as an App Link when installed, and falls back to the
  /// website when it is not.
  ///
  /// The path must stay in sync with [UserAppRoutes.productDetails], the
  /// intent-filter in AndroidManifest.xml, and the paths in
  /// `.well-known/apple-app-site-association`.
  static String product(String productId) => '$website/products/$productId';

  /// Shareable link for the challenges screen.
  ///
  /// Deliberately the list and not `/challenges/<id>`: there is no route, no
  /// intent-filter and no `apple-app-site-association` entry for a single
  /// challenge, so a per-challenge URL would open the website rather than the
  /// app. The share text names the challenge; this gets the recipient to the
  /// screen it lives on.
  static const String challenges = '$website/challenges';
}
