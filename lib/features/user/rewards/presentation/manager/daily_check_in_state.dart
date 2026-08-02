part of 'daily_check_in_cubit.dart';

sealed class DailyCheckInState {
  const DailyCheckInState();
}

class DailyCheckInInitial extends DailyCheckInState {
  const DailyCheckInInitial();
}

class DailyCheckInLoading extends DailyCheckInState {
  const DailyCheckInLoading();
}

/// The whole screen renders from [status] — the seven cards, the balance, the
/// button label and whether the button is enabled all come from it.
class DailyCheckInLoaded extends DailyCheckInState {
  final DailyCheckInStatusModel status;

  /// True while the claim request is in flight, so the button can lock without
  /// dropping the currently rendered cycle.
  final bool isClaiming;

  /// Set once after a successful claim so the UI can play the "+N" animation,
  /// then cleared by [DailyCheckInCubit.consumeAward].
  final int? justAwardedPoints;

  /// The backend's own translated message for the last claim attempt, success
  /// or failure. Always shown as-is — never replaced with app-side text.
  final String? message;
  final bool messageIsError;

  const DailyCheckInLoaded({
    required this.status,
    this.isClaiming = false,
    this.justAwardedPoints,
    this.message,
    this.messageIsError = false,
  });

  DailyCheckInLoaded copyWith({
    DailyCheckInStatusModel? status,
    bool? isClaiming,
    int? justAwardedPoints,
    String? message,
    bool? messageIsError,
  }) {
    return DailyCheckInLoaded(
      status: status ?? this.status,
      isClaiming: isClaiming ?? this.isClaiming,
      justAwardedPoints: justAwardedPoints,
      message: message,
      messageIsError: messageIsError ?? this.messageIsError,
    );
  }
}

class DailyCheckInFailure extends DailyCheckInState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const DailyCheckInFailure(this.message, {this.error});
}
