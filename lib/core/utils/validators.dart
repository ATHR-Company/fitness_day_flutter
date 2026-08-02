import 'package:easy_localization/easy_localization.dart';

/// Field rules shared by every form in the app.
///
/// They live here rather than being re-typed inside each screen's `validator:`
/// so a rule can only be wrong in one place — the password rule alone was
/// written out five times, and each copy allowed a password made entirely of
/// spaces.
class AppValidators {
  const AppValidators._();

  /// Empty, blank, and too-short passwords.
  ///
  /// A blank password is rejected on its own line: `"   "` is not empty, so an
  /// `isEmpty` check lets it through, and `"      "` even clears a six-character
  /// minimum. The backend then stores a password the user cannot retype
  /// deliberately.
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'login.password_error'.tr();
    }
    if (value.trim().isEmpty) {
      return 'login.password_blank'.tr();
    }
    if (value.length < minLength) {
      return 'login.password_too_short'.tr();
    }
    return null;
  }

  /// Sign-in only. Deliberately does **not** enforce the minimum length: an
  /// account created before the rule existed still has to be able to log in,
  /// and telling someone their *existing* password is too short helps nobody.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'login.password_error'.tr();
    }
    if (value.trim().isEmpty) {
      return 'login.password_blank'.tr();
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'login.password_error'.tr();
    }
    if (value != original) {
      return 'login.passwords_dont_match'.tr();
    }
    return null;
  }
}
