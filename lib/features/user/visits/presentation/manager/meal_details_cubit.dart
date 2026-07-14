import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_meal_details_usecase.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/update_meal_completion_usecase.dart';
import 'meal_details_state.dart';

class MealDetailsCubit extends Cubit<MealDetailsState> {
  final GetMealDetailsUseCase _getMealDetailsUseCase;
  final UpdateMealCompletionUseCase _updateMealCompletionUseCase;

  MealDetailsCubit({
    required GetMealDetailsUseCase getMealDetailsUseCase,
    required UpdateMealCompletionUseCase updateMealCompletionUseCase,
  })  : _getMealDetailsUseCase = getMealDetailsUseCase,
        _updateMealCompletionUseCase = updateMealCompletionUseCase,
        super(const MealDetailsInitial());

  Future<void> getMealDetails(
      String assessmentId, int dayNumber, String mealId) async {
    emit(const MealDetailsLoading());
    final result =
        await _getMealDetailsUseCase(assessmentId, dayNumber, mealId);
    switch (result) {
      case Success(:final data):
        emit(MealDetailsSuccess(data.data));
      case FailureResult(:final failure):
        emit(MealDetailsFailure(failure.message));
    }
  }

  Future<void> toggleMealCompletion(
      String assessmentId, int dayNumber, String mealId, bool isCompleted) async {
    final currentState = state;
    if (currentState is! MealDetailsSuccess) return;

    emit(MealDetailsSuccess(currentState.mealDetailsData, isUpdating: true));
    final result = await _updateMealCompletionUseCase(
        assessmentId, dayNumber, mealId, isCompleted);

    switch (result) {
      case Success(:final data):
        final updatedData = currentState.mealDetailsData.copyWith(
          isCompleted: data.data?.isCompleted ?? isCompleted,
        );
        emit(MealDetailsSuccess(updatedData, isUpdating: false));
      case FailureResult():
        emit(MealDetailsSuccess(currentState.mealDetailsData, isUpdating: false));
    }
  }
}
