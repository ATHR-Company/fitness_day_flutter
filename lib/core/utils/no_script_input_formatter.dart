import 'package:flutter/services.dart';

/// An [TextInputFormatter] that strips HTML tags and JavaScript-injection
/// patterns from user input in real time.
///
/// What it blocks:
///   - Any `<tag>` or `</tag>` construct (HTML / XML tags)
///   - `javascript:` URI schemes
///   - Common event-handler attributes (`on*=`)
///   - `<script`, `<iframe`, `<object`, `<embed`, `<form` fragments
///   - HTML entities used for encoding attacks (`&lt;`, `&gt;`, `&#`)
///
/// Usage — add to **any** [TextFormField] or [TextField] that accepts free text:
/// ```dart
/// TextFormField(
///   inputFormatters: [NoScriptInputFormatter()],
/// )
/// ```
///
/// For fields that already have other formatters (e.g. [LengthLimitingTextInputFormatter]),
/// simply include it alongside them — order does not matter for this formatter:
/// ```dart
/// inputFormatters: [
///   NoScriptInputFormatter(),
///   LengthLimitingTextInputFormatter(200),
/// ],
/// ```
class NoScriptInputFormatter extends TextInputFormatter {
  static final RegExp _pattern = RegExp(
    r'<[^>]*>'             // any HTML/XML tag: <div>, </div>, <br/>, etc.
    r'|javascript\s*:'     // javascript: URI
    r'|on\w+\s*='          // event handlers: onclick=, onload=, etc.
    r'|<\s*script'         // <script (with optional whitespace)
    r'|<\s*iframe'         // <iframe
    r'|<\s*object'         // <object
    r'|<\s*embed'          // <embed
    r'|<\s*form'           // <form
    r'|&lt;'               // HTML entity for <
    r'|&gt;'               // HTML entity for >
    r'|&#\d+;'             // decimal HTML entity e.g. &#60;
    r'|&#x[\da-fA-F]+;',   // hex HTML entity e.g. &#x3C;
    caseSensitive: false,
    multiLine: false,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String cleaned = newValue.text.replaceAll(_pattern, '');

    if (cleaned == newValue.text) return newValue;

    // The replacement removed some characters — keep the cursor at the same
    // logical position, clamped so it can never sit past the end of the
    // shortened text.
    final int removedBefore = newValue.selection.baseOffset -
        newValue.text
            .substring(0, newValue.selection.baseOffset)
            .replaceAll(_pattern, '')
            .length;

    final int newOffset =
        (newValue.selection.baseOffset - removedBefore).clamp(0, cleaned.length);

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

/// A [TextInputFormatter] that silently blocks any digit from being entered.
/// Use it on fields where numbers make no sense — names, food lists, allergies.
///
/// Covers Western `0-9`, Arabic-Indic `٠-٩` and Extended Arabic-Indic `۰-۹`.
/// `\d` alone matches only the Western ones, so an Arabic keyboard walked
/// straight past the old rule.
///
/// ```dart
/// inputFormatters: [
///   NoDigitsInputFormatter(),
///   LengthLimitingTextInputFormatter(30),
/// ],
/// ```
class NoDigitsInputFormatter extends TextInputFormatter {
  static final RegExp _digits = RegExp(r'[0-9٠-٩۰-۹]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String cleaned = newValue.text.replaceAll(_digits, '');
    if (cleaned == newValue.text) return newValue;

    final int removedBefore = newValue.selection.baseOffset -
        newValue.text
            .substring(0, newValue.selection.baseOffset)
            .replaceAll(_digits, '')
            .length;

    final int newOffset =
        (newValue.selection.baseOffset - removedBefore).clamp(0, cleaned.length);

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

/// A [TextInputFormatter] for name fields: **letters and spaces, nothing else**.
///
/// Allows:
///   - Latin letters (A-Z, a-z)
///   - Arabic letters, their diacritics/tashkeel, the extended letters
///     (pe, che, zhe ...) and the Unicode presentation forms
///   - Plain spaces
///
/// Blocks everything else - digits in any script, punctuation, symbols, emoji.
///
/// ```dart
/// inputFormatters: [
///   NameInputFormatter(),
///   LengthLimitingTextInputFormatter(30),
/// ],
/// ```
class NameInputFormatter extends TextInputFormatter {
  // Matches characters that are NOT allowed in a name.
  //
  // The ranges are listed one block at a time on purpose. The previous version
  // allowed ؀-ۿ wholesale, and that block contains the Arabic-Indic
  // digits (٠-٩) as well as the Arabic comma, semicolon and question
  // mark - so numbers and punctuation went straight through on an Arabic
  // keyboard. '.', '?' and '%' were allowed outright on top of that.
  static final RegExp _invalid = RegExp(
    r'[^'
    r'a-zA-Z'                       // Latin letters
    r'ء-غ'                // Arabic hamza .. ghain (stops before ٠)
    r'ف-ي'                // Arabic feh .. yeh (skips tatweel ـ)
    r'ً-ْٰ'          // tashkeel
    r'ٱ-ۓ'                // extended Arabic letters
    r'ﭐ-﷿ﹰ-﻿'   // Arabic presentation forms
    r' '                            // plain space only
    r']',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String cleaned = newValue.text.replaceAll(_invalid, '');
    if (cleaned == newValue.text) return newValue;

    final int removedBefore = newValue.selection.baseOffset -
        newValue.text
            .substring(0, newValue.selection.baseOffset)
            .replaceAll(_invalid, '')
            .length;

    final int newOffset =
        (newValue.selection.baseOffset - removedBefore).clamp(0, cleaned.length);

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
