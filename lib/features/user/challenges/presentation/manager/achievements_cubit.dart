import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitness_day/core/errors/app_error.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/challenges/data/models/achievement_model.dart';
import 'package:fitness_day/features/user/challenges/domain/usecases/challenges_usecases.dart';

sealed class AchievementsState {
  const AchievementsState();
}

class AchievementsLoading extends AchievementsState {
  const AchievementsLoading();
}

/// The badge wall — `GET /achievements`.
class AchievementsWallLoaded extends AchievementsState {
  final AchievementsWallModel wall;
  const AchievementsWallLoaded(this.wall);
}

/// The day strip screen — `GET /achievements/daily`.
class AchievementsDailyLoaded extends AchievementsState {
  final AchievementsDailyModel daily;

  /// True while a different chip's day is being fetched, so the strip stays on
  /// screen instead of collapsing to a spinner.
  final bool isSwitchingDay;

  const AchievementsDailyLoaded(this.daily, {this.isSwitchingDay = false});

  AchievementsDailyLoaded copyWith({
    AchievementsDailyModel? daily,
    bool? isSwitchingDay,
  }) {
    return AchievementsDailyLoaded(
      daily ?? this.daily,
      isSwitchingDay: isSwitchingDay ?? this.isSwitchingDay,
    );
  }
}

class AchievementsError extends AchievementsState {
  final String message;
  final AppError? error;
  const AchievementsError(this.message, {this.error});
}

/// Badges. Nothing here earns one — they unlock on the server during a sync,
/// and these calls only read what happened.
class AchievementsCubit extends Cubit<AchievementsState> {
  final GetAchievementsUseCase _getAchievementsUseCase;
  final GetDailyAchievementsUseCase _getDailyAchievementsUseCase;

  AchievementsCubit({
    required GetAchievementsUseCase getAchievementsUseCase,
    required GetDailyAchievementsUseCase getDailyAchievementsUseCase,
  })  : _getAchievementsUseCase = getAchievementsUseCase,
        _getDailyAchievementsUseCase = getDailyAchievementsUseCase,
        super(const AchievementsLoading());

  /// Everything, locked and unlocked — the locked ones are the point of the
  /// wall, so they are never filtered out here.
  Future<void> loadWall() async {
    emit(const AchievementsLoading());
    final result = await _getAchievementsUseCase();
    switch (result) {
      case Success(:final data):
        emit(AchievementsWallLoaded(data));
      case FailureResult(:final failure):
        emit(AchievementsError(failure.message, error: AppError.from(failure)));
    }
  }

  /// [date] as `YYYY-MM-DD`, or null for today. Tapping a chip in the strip
  /// re-calls this with that chip's `dayKey`.
  Future<void> loadDay({String? date}) async {
    final current = state;
    if (current is AchievementsDailyLoaded) {
      emit(current.copyWith(isSwitchingDay: true));
    } else {
      emit(const AchievementsLoading());
    }

    final result = await _getDailyAchievementsUseCase(date: date);
    switch (result) {
      case Success(:final data):
        emit(AchievementsDailyLoaded(data));
      case FailureResult(:final failure):
        // Keep the day already on screen rather than blanking the strip.
        final latest = state;
        if (latest is AchievementsDailyLoaded) {
          emit(latest.copyWith(isSwitchingDay: false));
          return;
        }
        emit(AchievementsError(failure.message, error: AppError.from(failure)));
    }
  }
}
