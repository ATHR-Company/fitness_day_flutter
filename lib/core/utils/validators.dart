import 'package:easy_localization/easy_localization.dart';

import 'package:fitness_day/core/utils/measurement.dart';

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

  /// Shortest name the backend accepts. Mirrored here so a name it would
  /// reject never leaves the device.
  static const int minNameLength = 2;

  /// A person's name — used by both the user and the specialist profile edits.
  static String? personName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'profile.name_cannot_be_empty'.tr();
    if (name.length < minNameLength) {
      return 'profile.name_too_short'.tr(namedArgs: {'min': '$minNameLength'});
    }
    return null;
  }

  /// Weight in kilogrammes. Accepts a decimal number inside
  /// [Measurement.minWeight]–[Measurement.maxWeight]; anything outside that is
  /// a typo, not a person.
  static String? weight(String? value) =>
      _weight(value, 'auth_val_err_weight');

  /// Height in centimetres, same shape as [weight].
  static String? height(String? value) =>
      _height(value, 'auth_val_err_height');

  /// [weight] worded for a specialist filling in someone else's report —
  /// "enter your weight" is wrong when the number belongs to the trainee.
  /// Only the missing-value message changes; the range message never names a
  /// person, so both flows share it.
  static String? clientWeight(String? value) =>
      _weight(value, 'visit_details.weight_required');

  /// [height] worded for the trainee, see [clientWeight].
  static String? clientHeight(String? value) =>
      _height(value, 'visit_details.height_required');

  static String? _weight(String? value, String missingKey) {
    final parsed = Measurement.parse(value);
    if (parsed == null) return missingKey.tr();
    if (!Measurement.isValidWeight(parsed)) {
      return 'auth_val_err_weight_range'.tr(namedArgs: {
        'min': Measurement.format(Measurement.minWeight),
        'max': Measurement.format(Measurement.maxWeight),
      });
    }
    return null;
  }

  static String? _height(String? value, String missingKey) {
    final parsed = Measurement.parse(value);
    if (parsed == null) return missingKey.tr();
    if (!Measurement.isValidHeight(parsed)) {
      return 'auth_val_err_height_range'.tr(namedArgs: {
        'min': Measurement.format(Measurement.minHeight),
        'max': Measurement.format(Measurement.maxHeight),
      });
    }
    return null;
  }
}
