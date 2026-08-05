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
  final Map<ProfileValidationKey, FocusNode> _focusNodes = {};

  ProfileValidationKey? _errorKey;
  String? _errorMessage;

  /// Frames to wait for this screen to become the visible route before giving
  /// up on scrolling/focusing. ~1s at 60fps — long enough for the pop
  /// animation, short enough that a screen that never gets revealed stops
  /// scheduling callbacks.
  static const int _maxRevealFrames = 60;

  /// The step this screen renders — errors for the other steps are ignored.
  ProfileSetupStep get validationStep;

  /// Anchor used to scroll the offending field into view. Pass it as the
  /// widget `key` of the input.
  GlobalKey fieldKey(ProfileValidationKey key) =>
      _fieldKeys.putIfAbsent(key, () => GlobalKey());

  /// Focus for the offending field. Pass it as the input's `focusNode` so a
  /// rejected value can be corrected without hunting for the field first.
  FocusNode fieldFocusNode(ProfileValidationKey key) =>
      _focusNodes.putIfAbsent(key, () => FocusNode());

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

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

    _revealWhenVisible(key, 0);
    return true;
  }

  /// Scrolls to [key]'s field and focuses it — but only once this screen is
  /// actually the route on top.
  ///
  /// The form is submitted from the *last* onboarding screen, so when the
  /// server rejects a field owned by an earlier one, this listener runs while
  /// that later screen is still covering us; it pops back in its own listener,
  /// which runs after ours. Scrolling and focusing right away therefore
  /// targeted an off-screen route and did nothing — the message was pinned to
  /// the field but the user came back to an unscrolled, unfocused form.
  void _revealWhenVisible(ProfileValidationKey key, int frame) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The user already started fixing something else, or we're gone.
      if (!mounted || _errorKey != key) return;

      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        if (frame < _maxRevealFrames) _revealWhenVisible(key, frame + 1);
        return;
      }

      final ctx = _fieldKeys[key]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.25,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
      _focusNodes[key]?.requestFocus();
    });
  }
}
