import 'package:fitness_day/core/errors/failures.dart';

/// What kind of thing went wrong — the one bit of information a screen needs in
/// order to decide *how* to show an error.
///
/// [Failure] already carries this distinction, but every state in the app stores
/// only `failure.message`, so by the time the UI sees it the kind is gone and
/// every error looks the same. [AppError] is what survives that trip.
enum AppErrorType {
  /// The request never reached a working server — no connection, or a timeout.
  /// Nothing is wrong with what the user asked for, so the screen offers Retry
  /// rather than explaining anything.
  network,

  /// The server answered and refused. The message is the backend's own text and
  /// is meant to be read, so it is shown where the user will actually see it.
  server,

  /// A [ServerFailure] that named the field it rejected. Screens with a form map
  /// [AppError.fieldKey] to the input and show the message under it instead of
  /// in a snackbar.
  validation,

  /// Local storage failed. Rare, and never the user's fault.
  cache,
}

/// A failure in the form the presentation layer can act on.
///
/// Build it once, in the cubit, from the `Failure` the repository returned:
///
/// ```dart
/// case FailureResult(:final failure):
///   emit(XFailure(failure.message, error: AppError.from(failure)));
/// ```
///
/// Then the screen picks the presentation — see `AppErrorView` for the
/// full-screen form and `showAppError` for the transient one.
class AppError {
  final AppErrorType type;

  /// Backend text for [AppErrorType.server], a localized fallback otherwise.
  final String message;

  /// Set only for [AppErrorType.validation] — the backend's `key` naming the
  /// rejected field.
  final String? fieldKey;

  const AppError({
    required this.type,
    required this.message,
    this.fieldKey,
  });

  factory AppError.from(Failure failure) {
    // ValidationFailure first: it extends ServerFailure, so the order matters.
    if (failure is ValidationFailure) {
      return AppError(
        type: AppErrorType.validation,
        message: failure.message,
        fieldKey: failure.key,
      );
    }
    if (failure is NetworkFailure) {
      return AppError(type: AppErrorType.network, message: failure.message);
    }
    if (failure is CacheFailure) {
      return AppError(type: AppErrorType.cache, message: failure.message);
    }
    return AppError(type: AppErrorType.server, message: failure.message);
  }

  /// For the few places that catch a raw exception instead of going through
  /// `ErrorHandler`. Treated as a server error — the safe default, since it
  /// shows the message rather than hiding it behind a Retry button.
  const AppError.unknown(this.message)
      : type = AppErrorType.server,
        fieldKey = null;
}
