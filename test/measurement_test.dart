import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_day/core/utils/decimal_input_formatter.dart';
import 'package:fitness_day/core/utils/measurement.dart';

/// Runs [DecimalInputFormatter] over [text] as if it had just been typed.
String _format(String text, {DecimalInputFormatter? formatter}) {
  return (formatter ?? DecimalInputFormatter())
      .formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        ),
      )
      .text;
}

void main() {
  group('Measurement.format', () {
    test('caps at two decimals', () {
      expect(Measurement.format(50.066556668568886), '50.07');
      expect(Measurement.format(155.09989859899), '155.1');
    });

    test('drops trailing zeros', () {
      expect(Measurement.format(155.0), '155');
      expect(Measurement.format(70.50), '70.5');
    });
  });

  group('Measurement.parse', () {
    test('ignores a trailing unit', () {
      expect(Measurement.parse('70.5 كجم'), 70.5);
      expect(Measurement.parse('155 cm'), 155);
    });

    test('accepts Arabic-Indic digits and a comma separator', () {
      expect(Measurement.parse('١٥٥٫٥'), 155.5);
      expect(Measurement.parse('50,25'), 50.25);
    });

    test('returns null when there is no number', () {
      expect(Measurement.parse('abc'), isNull);
      expect(Measurement.parse(''), isNull);
      expect(Measurement.parse(null), isNull);
    });
  });

  group('Measurement.normalize', () {
    test('rounds what gets sent to the API', () {
      expect(Measurement.normalize('50.066556668568886'), '50.07');
      expect(Measurement.normalize('155.0'), '155');
      expect(Measurement.normalize('nope'), isNull);
    });
  });

  group('DecimalInputFormatter', () {
    test('keeps at most two decimals', () {
      expect(_format('12.345'), '12.34');
      expect(_format('12.3'), '12.3');
    });

    test('keeps only the first dot', () {
      expect(_format('1.2.3'), '1.23');
    });

    test('drops a leading dot', () {
      expect(_format('.5'), '5');
    });

    test('caps the integer part', () {
      expect(_format('9999'), '999');
      // The 4th integer digit is dropped; the decimals still land.
      expect(_format('1234.56'), '123.56');
    });

    test('normalizes Arabic digits and a comma separator', () {
      expect(_format('١٢٣'), '123');
      expect(_format('50,25'), '50.25');
    });

    test('strips letters and symbols', () {
      expect(_format('7a0!'), '70');
    });
  });

  group('Measurement range guards', () {
    test('match the sign-up wheel pickers', () {
      expect(Measurement.isValidWeight(20), isTrue);
      expect(Measurement.isValidWeight(200), isTrue);
      expect(Measurement.isValidWeight(19.9), isFalse);
      expect(Measurement.isValidWeight(200.1), isFalse);

      expect(Measurement.isValidHeight(50), isTrue);
      expect(Measurement.isValidHeight(280), isTrue);
      expect(Measurement.isValidHeight(49.9), isFalse);
      expect(Measurement.isValidHeight(280.1), isFalse);
    });
  });
}
