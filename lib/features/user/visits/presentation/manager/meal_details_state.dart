import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';

sealed class MealDetailsState {
  const MealDetailsState();
}

class MealDetailsInitial extends MealDetailsState {
  const MealDetailsInitial();
}

class MealDetailsLoading extends MealDetailsState {
  const MealDetailsLoading();
}

class MealDetailsSuccess extends MealDetailsState {
  final MealDetailsData mealDetailsData;
  final bool isUpdating;
  const MealDetailsSuccess(this.mealDetailsData, {this.isUpdating = false});
}

class MealDetailsFailure extends MealDetailsState {
  final String message;
  const MealDetailsFailure(this.message);
}
