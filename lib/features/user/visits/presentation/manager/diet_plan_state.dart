import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';

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
  const DietPlanFailure(this.message);
}
