import 'package:fitness_day/features/user/workout/data/models/workout_plan_model.dart';

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
  final List<WorkoutItemModel> workouts;

  const WorkoutPlanSuccess(this.workouts);
}

class WorkoutPlanFailure extends WorkoutPlanState {
  final String message;

  const WorkoutPlanFailure(this.message);
}
