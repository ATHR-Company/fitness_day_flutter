import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/widgets/app_snack_bar.dart';
import 'package:fitness_day/core/widgets/errors/app_error_dialog.dart';

/// How an error interrupts the user.
enum ErrorDisplay {
  /// Passes by on its own. The default, and correct for almost everything: a
  /// list that failed to refresh, a bookmark that did not save, a form the
  /// backend rejected.
  snackBar,

  /// Has to be dismissed. Only for failures the user must register before
  /// moving on — payment, orders, account actions.
  dialog,
}

/// Shows an error **over** the current screen, keeping whatever content is
/// already there.
///
/// This is the right call whenever the screen has something on it. Use
/// `AppErrorView` instead only when a first load failed and there is nothing
/// to show behind the error.
///
/// ```dart
/// BlocListener<XCubit, XState>(
///   listener: (context, state) {
///     if (state is XFailure) showAppError(context, state.error);
///   },
///   ...
/// )
/// ```
///
/// Pass [onRetry] to offer the action again; the dialog renders it as a second
/// button and the snackbar ignores it (a snackbar is gone before it could be
/// tapped reliably).
void showAppError(
  BuildContext context,
  AppError? error, {
  String? message,
  ErrorDisplay display = ErrorDisplay.snackBar,
  VoidCallback? onRetry,
}) {
  final String text = _textFor(error, message);

  switch (display) {
    case ErrorDisplay.snackBar:
      showAppSnackBar(context, text: text, isError: true);
    case ErrorDisplay.dialog:
      showDialog<void>(
        context: context,
        builder: (_) => AppErrorDialog(
          error: error,
          message: message,
          onRetry: onRetry,
        ),
      );
  }
}

/// A connection failure's message is an internal constant, so the localized
/// copy reads better. A server failure's message is the backend's own text and
/// is the entire point of showing anything, so it wins.
String _textFor(AppError? error, String? fallback) {
  if (error?.type == AppErrorType.network) {
    return 'errors.no_internet_subtitle'.tr();
  }
  final String? text = error?.message ?? fallback;
  if (text != null && text.trim().isNotEmpty) return text;
  return 'errors.generic_subtitle'.tr();
}
