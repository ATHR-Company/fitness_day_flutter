/// Weight (kg) and height (cm) — the one place their precision and range are
/// decided.
///
/// The backend echoes back whatever floating-point value it computed, so a
/// profile edit could come back as `50.066556668568886 kg` and get rendered
/// character-for-character. Everything user-facing goes through [format], and
/// everything sent to the API goes through [normalize], so neither the screen
/// nor the server ever sees more precision than a bathroom scale has.
class Measurement {
  const Measurement._();

  /// Mirrors the bounds of the sign-up wheel pickers (`WeightPickerDialog`,
  /// `HeightPickerDialog`) so a value the picker can produce is never rejected
  /// by the validator on a later edit.
  static const double minWeight = 20;
  static const double maxWeight = 200;
  static const double minHeight = 50;
  static const double maxHeight = 280;

  /// How many decimals a weight/height may carry.
  static const int decimals = 2;

  /// Arabic-Indic (٠-٩) and Extended Arabic-Indic (۰-۹) digits, in order.
  static const String _arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  static const String _extendedArabicIndic = '۰۱۲۳۴۵۶۷۸۹';

  /// Rewrites Arabic-Indic digits as ASCII and both decimal separators (`,`
  /// and the Arabic `٫`) as a dot, so an Arabic keyboard produces something
  /// [double.tryParse] understands.
  static String toAscii(String raw) {
    final buffer = StringBuffer();
    for (final rune in raw.runes) {
      final char = String.fromCharCode(rune);
      final arabicIndex = _arabicIndic.indexOf(char);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
        continue;
      }
      final extendedIndex = _extendedArabicIndic.indexOf(char);
      if (extendedIndex != -1) {
        buffer.write(extendedIndex);
        continue;
      }
      buffer.write(char == ',' || char == '٫' ? '.' : char);
    }
    return buffer.toString();
  }

  /// Parses user input into a number, tolerating Arabic digits, a comma
  /// decimal separator, surrounding spaces and a trailing unit ("70.5 كجم").
  /// Returns `null` when there is no number in there at all.
  static double? parse(String? raw) {
    if (raw == null) return null;
    final ascii = toAscii(raw).replaceAll(RegExp(r'[^0-9.]'), '');
    if (ascii.isEmpty) return null;
    final value = double.tryParse(ascii);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }

  /// Rounds to [decimals] places — the value actually stored and submitted.
  static double round(double value) =>
      double.parse(value.toStringAsFixed(decimals));

  /// The string sent to the API: at most two decimals, ASCII digits, no unit.
  /// Returns `null` when [raw] holds no usable number.
  static String? normalize(String? raw) {
    final value = parse(raw);
    return value == null ? null : format(value);
  }

  /// Display form: `50.066556668568886` → `50.07`, `155.0` → `155`.
  ///
  /// Trailing zeros are dropped because "155.00 cm" reads as a measurement
  /// taken to the hundredth of a centimetre, which it is not.
  static String format(num value) {
    final fixed = value.toDouble().toStringAsFixed(decimals);
    if (!fixed.contains('.')) return fixed;
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  /// `70.5` → `"70.5 كجم"`. Pass the already-translated [unit].
  static String withUnit(num value, String unit) => '${format(value)} $unit';

  static bool isValidWeight(double value) =>
      value >= minWeight && value <= maxWeight;

  static bool isValidHeight(double value) =>
      value >= minHeight && value <= maxHeight;
}
