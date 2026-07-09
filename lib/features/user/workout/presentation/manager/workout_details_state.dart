import 'package:fitness_day/features/user/workout/data/models/workout_details_model.dart';
import 'package:fitness_day/features/user/workout/data/models/complete_workout_set_model.dart';

sealed class WorkoutDetailsState {
  const WorkoutDetailsState();
}

class WorkoutDetailsInitial extends WorkoutDetailsState {
  const WorkoutDetailsInitial();
}

class WorkoutDetailsLoading extends WorkoutDetailsState {
  const WorkoutDetailsLoading();
}

class WorkoutDetailsSuccess extends WorkoutDetailsState {
  final WorkoutDetailsModel workout;

  const WorkoutDetailsSuccess(this.workout);
}

class WorkoutDetailsFailure extends WorkoutDetailsState {
  final String message;

  const WorkoutDetailsFailure(this.message);
}

class WorkoutSetCompletionSuccess extends WorkoutDetailsState {
  final CompleteWorkoutSetData completionData;

  const WorkoutSetCompletionSuccess(this.completionData);
}

class WorkoutSetCompletionLoading extends WorkoutDetailsState {
  const WorkoutSetCompletionLoading();
}

class WorkoutSetCompletionFailure extends WorkoutDetailsState {
  final String message;

  const WorkoutSetCompletionFailure(this.message);
}
