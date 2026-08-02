import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/claim_daily_check_in_usecase.dart';
import 'package:fitness_day/features/user/rewards/domain/usecases/get_daily_check_in_status_usecase.dart';
import 'package:fitness_day/core/errors/app_error.dart';

part 'daily_check_in_state.dart';

/// Drives the daily check-in dialog straight off the server.
///
/// The cycle, the streak and "is today claimed" are never computed here: the
/// backend recomputes all of it on every request, so a wrong device clock, a
/// user in another timezone, or an app that slept for three days all still show
/// the same thing. Nothing is persisted between sessions.
class DailyCheckInCubit extends Cubit<DailyCheckInState> {
  final GetDailyCheckInStatusUseCase _getStatusUseCase;
  final ClaimDailyCheckInUseCase _claimUseCase;

  DailyCheckInCubit({
    required GetDailyCheckInStatusUseCase getStatusUseCase,
    required ClaimDailyCheckInUseCase claimUseCase,
  })  : _getStatusUseCase = getStatusUseCase,
        _claimUseCase = claimUseCase,
        super(const DailyCheckInInitial());

  /// Call when the screen opens and whenever the app returns to the foreground
  /// — the state changes on its own with the passage of time.
  Future<void> loadStatus() async {
    if (isClosed) return;
    emit(const DailyCheckInLoading());

    final result = await _getStatusUseCase();
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(DailyCheckInLoaded(status: data));
      case FailureResult(:final failure):
        emit(DailyCheckInFailure(failure.message, error: AppError.from(failure)));
    }
  }

  /// The "استلم جائزتك" button. The response is a full status document, so the
  /// screen re-renders from it rather than patching anything locally — and
  /// `status` is deliberately **not** called again afterwards.
  Future<void> claim() async {
    final current = state;
    if (current is! DailyCheckInLoaded || current.isClaiming) return;

    emit(current.copyWith(isClaiming: true));

    final result = await _claimUseCase();
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(DailyCheckInLoaded(
          status: data,
          justAwardedPoints: data.pointsAwarded,
          message: null,
        ));
      case FailureResult(:final failure):
        // "لقد استلمت جائزة اليوم بالفعل" lands here — a double tap, or a
        // screen left open past midnight UTC. Not a bug: show the backend's
        // message and refresh so the cards match the server again.
        emit(current.copyWith(
          isClaiming: false,
          message: failure.message,
          messageIsError: true,
        ));
        await loadStatus();
    }
  }

  /// Clears the one-shot award/message so a rebuild doesn't replay them.
  void consumeAward() {
    final current = state;
    if (current is! DailyCheckInLoaded) return;
    if (current.justAwardedPoints == null && current.message == null) return;
    emit(DailyCheckInLoaded(status: current.status));
  }
}
