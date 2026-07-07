import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_details_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/complete_workout_set_usecase.dart';
import 'workout_details_state.dart';

class WorkoutDetailsCubit extends Cubit<WorkoutDetailsState> {
  final GetWorkoutDetailsUseCase _getWorkoutDetailsUseCase;
  final CompleteWorkoutSetUseCase _completeWorkoutSetUseCase;

  WorkoutDetailsCubit({
    required GetWorkoutDetailsUseCase getWorkoutDetailsUseCase,
    required CompleteWorkoutSetUseCase completeWorkoutSetUseCase,
  })  : _getWorkoutDetailsUseCase = getWorkoutDetailsUseCase,
        _completeWorkoutSetUseCase = completeWorkoutSetUseCase,
        super(const WorkoutDetailsInitial());

  Future<void> getWorkoutDetails(String workoutItemId) async {
    emit(const WorkoutDetailsLoading());
    final result = await _getWorkoutDetailsUseCase(workoutItemId);
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(WorkoutDetailsSuccess(data.data!));
        } else {
          emit(const WorkoutDetailsFailure('No details found for this workout.'));
        }
      case FailureResult(:final failure):
        emit(WorkoutDetailsFailure(failure.message));
    }
  }

  Future<void> completeWorkoutSet({
    required int dayNumber,
    required String workoutItemId,
    required int setNumber,
  }) async {
    emit(const WorkoutSetCompletionLoading());
    final result = await _completeWorkoutSetUseCase(
      dayNumber: dayNumber,
      workoutItemId: workoutItemId,
      setNumber: setNumber,
    );
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(WorkoutSetCompletionSuccess(data.data!));
        } else {
          emit(const WorkoutSetCompletionFailure('Failed to complete set.'));
        }
      case FailureResult(:final failure):
        emit(WorkoutSetCompletionFailure(failure.message));
    }
  }
}
