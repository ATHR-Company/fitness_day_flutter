/// Links used when sharing the app with friends.
///
/// NOTE: these are placeholders. The bundle ids are still the Flutter defaults
/// (`com.example.fitness_day` on Android, `com.example.fitnessDay` on iOS), so
/// the store listings below do not exist yet. Update all three values once the
/// app is published — this is the only place they are defined.
class AppShareLinks {
  const AppShareLinks._();

  static const String website = 'https://fitnessday.tech';

  /// TODO: replace with the real Play Store listing after publishing.
  static const String androidStore =
      'https://play.google.com/store/apps/details?id=com.example.fitness_day';

  /// TODO: replace with the real App Store listing after publishing.
  static const String iosStore = 'https://apps.apple.com/app/id000000000';

  /// Shareable web link for a product. Kept on the [website] domain so that
  /// once the real bundle ids are set and the domain serves `assetlinks.json` /
  /// `apple-app-site-association`, these exact links start opening the app
  /// directly as App Links — no change to what has already been shared.
  static String product(String productId) => '$website/products/$productId';
}
