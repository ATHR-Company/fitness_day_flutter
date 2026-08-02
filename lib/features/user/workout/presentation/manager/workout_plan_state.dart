import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class WorkoutPlanState {
  const WorkoutPlanState();
}

class WorkoutPlanInitial extends WorkoutPlanState {
  const WorkoutPlanInitial();
}

class WorkoutPlanLoading extends WorkoutPlanState {
  const WorkoutPlanLoading();
}

class WorkoutPlanSuccess extends WorkoutPlanState {
  final WorkoutPlanData? workoutPlanData;

  const WorkoutPlanSuccess(this.workoutPlanData);
}

class WorkoutPlanFailure extends WorkoutPlanState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;

  const WorkoutPlanFailure(this.message, {this.error});
}
