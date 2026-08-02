import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_plan_usecase.dart';
import 'workout_plan_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final GetWorkoutPlanUseCase _getWorkoutPlanUseCase;

  /// Live patches from the workout details / video screens — see
  /// [AppEventBus].
  late final StreamSubscription<AppEvent> _progressSub;

  WorkoutPlanCubit(this._getWorkoutPlanUseCase)
      : super(const WorkoutPlanInitial()) {
    _progressSub = getIt<AppEventBus>().stream.listen(_applyProgressEvent);
  }

  @override
  Future<void> close() {
    _progressSub.cancel();
    return super.close();
  }

  Future<void> getWorkoutPlan(int dayNumber) async {
    emit(const WorkoutPlanLoading());
    final result = await _getWorkoutPlanUseCase(dayNumber);
    switch (result) {
      case Success(:final data):
        emit(WorkoutPlanSuccess(data.data));
      case FailureResult(:final failure):
        emit(WorkoutPlanFailure(failure.message, error: AppError.from(failure)));
    }
  }

  /// Updates the set counter on the one exercise the user just worked through,
  /// without refetching the day. Only workout events apply here.
  void _applyProgressEvent(AppEvent event) {
    if (event is! WorkoutProgressChanged) return;

    final WorkoutPlanState current = state;
    if (current is! WorkoutPlanSuccess) return;

    final WorkoutPlanData? plan = current.workoutPlanData;
    if (plan == null) return;

    // The page can be showing any day of the plan.
    if (plan.assessmentId != event.assessmentId ||
        plan.dayNumber != event.dayNumber) {
      return;
    }

    final int index =
        plan.workouts.indexWhere((w) => w.id == event.workoutItemId);
    if (index == -1) return;

    final List<WorkoutItemModel> workouts =
        List<WorkoutItemModel>.of(plan.workouts);
    workouts[index] = workouts[index].copyWith(
      completedSets: event.completedSets,
      totalSets: event.totalSets,
      isCompleted: event.isCompleted,
    );
    emit(WorkoutPlanSuccess(plan.copyWith(workouts: workouts)));
  }
}
