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
  const MealDetailsSuccess(this.mealDetailsData);
}

class MealDetailsFailure extends MealDetailsState {
  final String message;
  const MealDetailsFailure(this.message);
}
