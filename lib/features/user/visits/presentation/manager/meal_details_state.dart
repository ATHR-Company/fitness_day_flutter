import 'package:fitness_day/features/user/visits/data/models/meal_details_model.dart';
import 'package:fitness_day/core/errors/app_error.dart';

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

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  const MealDetailsFailure(this.message, {this.error});
}
