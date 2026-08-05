import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_day/core/utils/no_script_input_formatter.dart';

/// Runs [formatter] over [text] as if it had just been typed.
String _run(TextInputFormatter formatter, String text) {
  return formatter
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
  group('NameInputFormatter', () {
    final formatter = NameInputFormatter();

    test('keeps Latin and Arabic letters and spaces', () {
      expect(_run(formatter, 'Kareem Alfara'), 'Kareem Alfara');
      expect(_run(formatter, 'كريم الفرا'), 'كريم الفرا');
    });

    test('strips Western digits', () {
      expect(_run(formatter, 'Kareem123'), 'Kareem');
    });

    test('strips Arabic-Indic digits', () {
      // The old ٠٦٠٠-٠٦FF catch-all let these through.
      expect(_run(formatter, 'كريم٢٠٢٥'), 'كريم');
      expect(_run(formatter, 'كريم۲۳'), 'كريم');
    });

    test('strips Arabic punctuation', () {
      expect(_run(formatter, 'كريم،الفرا'), 'كريمالفرا');
      expect(_run(formatter, 'كريم؟'), 'كريم');
      expect(_run(formatter, 'كريم؛'), 'كريم');
    });

    test('strips the dot, question mark and percent that used to be allowed', () {
      expect(_run(formatter, 'A. Smith'), 'A Smith');
      expect(_run(formatter, 'Kareem?'), 'Kareem');
      expect(_run(formatter, '100% Kareem'), ' Kareem');
    });

    test('strips symbols and emoji', () {
      expect(_run(formatter, 'Kareem@#\$'), 'Kareem');
      expect(_run(formatter, 'Kareem🎉'), 'Kareem');
      expect(_run(formatter, '<b>Kareem</b>'), 'bKareemb');
    });

    test('strips tatweel', () {
      expect(_run(formatter, 'كــريم'), 'كريم');
    });

    test('keeps tashkeel', () {
      expect(_run(formatter, 'كَرِيم'), 'كَرِيم');
    });
  });

  group('NoDigitsInputFormatter', () {
    final formatter = NoDigitsInputFormatter();

    test('strips digits in every script', () {
      expect(_run(formatter, 'لبن 2 بيض'), 'لبن  بيض');
      expect(_run(formatter, 'لبن ٢ بيض'), 'لبن  بيض');
      expect(_run(formatter, 'لبن ۲ بيض'), 'لبن  بيض');
    });

    test('leaves list separators alone — food fields are prose', () {
      expect(_run(formatter, 'لبن، بيض، مكسرات'), 'لبن، بيض، مكسرات');
      expect(_run(formatter, 'milk, eggs, nuts'), 'milk, eggs, nuts');
    });
  });
}
