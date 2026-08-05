import 'package:flutter/services.dart';

import 'package:fitness_day/core/utils/measurement.dart';

/// A [TextInputFormatter] for decimal number fields (weight, height, …).
///
/// It keeps the field in a state that is always parseable rather than
/// validating after the fact:
///   - Arabic-Indic digits and a comma separator are rewritten to ASCII
///   - everything that is not a digit or a dot is dropped
///   - only the first dot survives
///   - at most [decimalRange] digits after the dot, [maxIntegerDigits] before
///
/// ```dart
/// TextField(
///   keyboardType: const TextInputType.numberWithOptions(decimal: true),
///   inputFormatters: [DecimalInputFormatter()],
/// )
/// ```
class DecimalInputFormatter extends TextInputFormatter {
  final int decimalRange;
  final int maxIntegerDigits;

  DecimalInputFormatter({
    this.decimalRange = Measurement.decimals,
    this.maxIntegerDigits = 3,
  })  : assert(decimalRange >= 0),
        assert(maxIntegerDigits > 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final cleaned = _clean(newValue.text);
    if (cleaned == newValue.text) return newValue;

    // Keep the caret where the user left it, minus whatever was dropped
    // before it, clamped so it can never sit past the end of the new text.
    final head = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final keptBefore = _clean(newValue.text.substring(0, head)).length;

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(
        offset: keptBefore.clamp(0, cleaned.length),
      ),
    );
  }

  String _clean(String raw) {
    final buffer = StringBuffer();
    var integerDigits = 0;
    var decimalDigits = 0;
    var seenDot = false;

    for (final char in Measurement.toAscii(raw).split('')) {
      if (char == '.') {
        // A leading dot has no integer part to attach to — ".5" is easier to
        // reject here than to explain in an error message.
        if (seenDot || decimalRange == 0 || integerDigits == 0) continue;
        seenDot = true;
        buffer.write(char);
        continue;
      }
      final code = char.codeUnitAt(0);
      if (code < 0x30 || code > 0x39) continue;
      if (seenDot) {
        if (decimalDigits >= decimalRange) continue;
        decimalDigits++;
      } else {
        if (integerDigits >= maxIntegerDigits) continue;
        integerDigits++;
      }
      buffer.write(char);
    }

    return buffer.toString();
  }
}
