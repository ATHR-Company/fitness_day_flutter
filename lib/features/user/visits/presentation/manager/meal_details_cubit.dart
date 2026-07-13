import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/domain/usecases/get_meal_details_usecase.dart';
import 'meal_details_state.dart';

class MealDetailsCubit extends Cubit<MealDetailsState> {
  final GetMealDetailsUseCase _getMealDetailsUseCase;

  MealDetailsCubit({
    required GetMealDetailsUseCase getMealDetailsUseCase,
  })  : _getMealDetailsUseCase = getMealDetailsUseCase,
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
}
