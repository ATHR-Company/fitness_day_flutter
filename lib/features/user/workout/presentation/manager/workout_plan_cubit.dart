import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_plan_usecase.dart';
import 'workout_plan_state.dart';

class WorkoutPlanCubit extends Cubit<WorkoutPlanState> {
  final GetWorkoutPlanUseCase _getWorkoutPlanUseCase;

  WorkoutPlanCubit(this._getWorkoutPlanUseCase) : super(const WorkoutPlanInitial());

  Future<void> getWorkoutPlan(int dayNumber) async {
    emit(const WorkoutPlanLoading());
    final result = await _getWorkoutPlanUseCase(dayNumber);
    switch (result) {
      case Success(:final data):
        emit(WorkoutPlanSuccess(data.data));
      case FailureResult(:final failure):
        emit(WorkoutPlanFailure(failure.message));
    }
  }
}
