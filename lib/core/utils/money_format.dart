import 'package:easy_localization/easy_localization.dart';

/// The currency the backend is settling in.
///
/// The API reports `currency` on every payment and order response. Product,
/// plan and cart responses do **not** carry one, so this holds the last code
/// the backend reported and those screens fall back to it — that way a single
/// backend config change (EGP sandbox → SAR production) flows through the
/// whole app without touching any code.
///
/// Same shape as [AppLocale]: set it whenever the API tells us something new.
class AppCurrency {
  AppCurrency._();

  /// Production settles in SAR, so that is the starting assumption until the
  /// first API response says otherwise.
  static String _code = 'SAR';

  static String get code => _code;

  /// Call with whatever `currency` the API returned.
  static void set(String? code) {
    if (code == null || code.trim().isEmpty) return;
    _code = code.trim().toUpperCase();
  }
}

/// Localized symbol for [code], falling back to the code itself.
///
/// The fallback is what keeps this honest: a currency the app has never been
/// told about still renders correctly instead of showing the wrong symbol.
String currencySymbol(String? code) {
  final String resolved = (code == null || code.trim().isEmpty)
      ? AppCurrency.code
      : code.trim().toUpperCase();

  return switch (resolved) {
    'SAR' => 'currency.sar'.tr(),
    'EGP' => 'currency.egp'.tr(),
    _ => resolved,
  };
}

/// `"585.98 ر.س"` — an amount next to its currency.
///
/// Decimals are kept when the amount has them and dropped when it doesn't, so
/// a 3500 plan reads "3500" while a 585.98 order keeps its halalas/piastres
/// instead of being truncated to 585.
String formatMoney(num amount, {String? currency}) =>
    '${formatAmount(amount)} ${currencySymbol(currency)}';

/// The number on its own, for layouts that render the currency separately.
String formatAmount(num amount) {
  final double value = amount.toDouble();
  return value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}
