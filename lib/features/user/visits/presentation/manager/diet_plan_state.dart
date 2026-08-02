import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class DietPlanState {
  const DietPlanState();
}

class DietPlanInitial extends DietPlanState {
  const DietPlanInitial();
}

class DietPlanLoading extends DietPlanState {
  const DietPlanLoading();
}

class DietPlanSuccess extends DietPlanState {
  final DietPlanData? dietPlanData;
  const DietPlanSuccess(this.dietPlanData);
}

class DietPlanFailure extends DietPlanState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  const DietPlanFailure(this.message, {this.error});
}
