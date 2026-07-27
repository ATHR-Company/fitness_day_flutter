import 'package:flutter/material.dart';

import 'package:fitness_day/features/user/auth/domain/entities/profile_validation_key.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_state.dart';

/// Shared plumbing for the three onboarding screens that feed
/// `POST /users/complete-personal-data`.
///
/// The request is only sent from the last screen, but the backend can reject a
/// value entered on any of them. It reports which one via `key`, so each screen
/// picks up the errors it owns, pins the message under that input and scrolls
/// it into view.
mixin ProfileValidationErrors<T extends StatefulWidget> on State<T> {
  final Map<ProfileValidationKey, GlobalKey> _fieldKeys = {};

  ProfileValidationKey? _errorKey;
  String? _errorMessage;

  /// The step this screen renders — errors for the other steps are ignored.
  ProfileSetupStep get validationStep;

  /// Anchor used to scroll the offending field into view. Pass it as the
  /// widget `key` of the input.
  GlobalKey fieldKey(ProfileValidationKey key) =>
      _fieldKeys.putIfAbsent(key, () => GlobalKey());

  /// The server message to render under [key], or null when it's fine.
  String? errorFor(ProfileValidationKey key) =>
      _errorKey == key ? _errorMessage : null;

  bool get hasServerError => _errorKey != null;

  /// Drops the message once the user starts fixing the value — wire it to the
  /// controllers so the red text doesn't linger on an edited field.
  void clearServerError() {
    if (_errorKey == null || !mounted) return;
    setState(() {
      _errorKey = null;
      _errorMessage = null;
    });
  }

  /// Adopts [failure] when it belongs to this screen.
  /// Returns false when the error is generic or owned by another step, so the
  /// caller can fall back to a snack bar / navigate to the right screen.
  bool handleValidationFailure(UserSetupFailure failure) {
    final key = failure.fieldKey;
    if (key == null || key.step != validationStep) return false;

    setState(() {
      _errorKey = key;
      _errorMessage = failure.message;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _fieldKeys[key]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0.25,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
    return true;
  }
}
