import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/services/app_event_bus.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/get_workout_details_usecase.dart';
import 'package:fitness_day/features/user/workout/domain/usecases/complete_workout_set_usecase.dart';
import 'workout_details_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class WorkoutDetailsCubit extends Cubit<WorkoutDetailsState> {
  final GetWorkoutDetailsUseCase _getWorkoutDetailsUseCase;
  final CompleteWorkoutSetUseCase _completeWorkoutSetUseCase;

  WorkoutDetailsCubit({
    required GetWorkoutDetailsUseCase getWorkoutDetailsUseCase,
    required CompleteWorkoutSetUseCase completeWorkoutSetUseCase,
  })  : _getWorkoutDetailsUseCase = getWorkoutDetailsUseCase,
        _completeWorkoutSetUseCase = completeWorkoutSetUseCase,
        super(const WorkoutDetailsInitial());

  Future<void> getWorkoutDetails(
      String assessmentId, int dayNumber, String workoutItemId) async {
    emit(const WorkoutDetailsLoading());
    final result = await _getWorkoutDetailsUseCase(
        assessmentId, dayNumber, workoutItemId);
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(WorkoutDetailsSuccess(data.data!));
        } else {
          emit(const WorkoutDetailsFailure('No details found for this workout.'));
        }
      case FailureResult(:final failure):
        emit(WorkoutDetailsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> completeWorkoutSet({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
    required int setNumber,
  }) async {
    emit(const WorkoutSetCompletionLoading());
    final result = await _completeWorkoutSetUseCase(
      assessmentId: assessmentId,
      dayNumber: dayNumber,
      workoutItemId: workoutItemId,
      setNumber: setNumber,
    );
    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          emit(WorkoutSetCompletionSuccess(data.data!));
          // The response already carries the new counters, so the home and
          // today-tasks cards can be patched from it — no refetch needed.
          getIt<AppEventBus>().publish(WorkoutProgressChanged(
            assessmentId: assessmentId,
            dayNumber: dayNumber,
            workoutItemId: workoutItemId,
            completedSets: data.data!.completedSets,
            totalSets: data.data!.totalSets,
            isCompleted: data.data!.isCompleted,
          ));
        } else {
          emit(const WorkoutSetCompletionFailure('Failed to complete set.'));
        }
      case FailureResult(:final failure):
        emit(WorkoutSetCompletionFailure(failure.message, error: AppError.from(failure)));
    }
  }
}
