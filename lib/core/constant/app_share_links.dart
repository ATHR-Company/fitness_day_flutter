/// Links used when sharing the app with friends.
///
/// The only place these are defined — update here, not at the call sites.
class AppShareLinks {
  const AppShareLinks._();

  static const String website = 'https://fitnessday.tech';

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
}
