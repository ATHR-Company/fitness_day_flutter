import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/assessment_current_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_visit_data_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/start_visit_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_goal_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_client_notes_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';
import 'visit_details_state.dart';
import 'package:fitness_day/core/errors/app_error.dart';

class VisitDetailsCubit extends Cubit<VisitDetailsState> {
  final GetVisitDataUseCase _getVisitDataUseCase;
  final GetHealthReportUseCase _getHealthReportUseCase;
  final GetCustomPlanUseCase _getCustomPlanUseCase;
  final StartVisitUseCase _startVisitUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final UpdateClientNotesUseCase _updateClientNotesUseCase;
  final UpdateHealthReportUseCase _updateHealthReportUseCase;
  final SpecialistVisitsRepository _repository;

  VisitDetailsCubit(
    this._getVisitDataUseCase,
    this._getHealthReportUseCase,
    this._getCustomPlanUseCase,
    this._startVisitUseCase,
    this._updateGoalUseCase,
    this._updateClientNotesUseCase,
    this._updateHealthReportUseCase,
    this._updateCustomPlanUseCase,
    this._repository,
  ) : super(const VisitDetailsInitial());

  final UpdateCustomPlanUseCase _updateCustomPlanUseCase;

  Future<void> loadVisitData(String assessmentId, {bool forceRefresh = false}) async {
    final currentState = state;
    if (!forceRefresh && currentState is VisitDetailsSuccess && currentState.visitData != null) {
      // Already cached
      return;
    }

    emit(const VisitDetailsLoading());

    final result = await _getVisitDataUseCase(assessmentId: assessmentId);

    final baseState = currentState is VisitDetailsSuccess ? currentState : null;

    switch (result) {
      case Success(:final data):
        final isStartedFromApi = data.data?.isStarted ?? false;
        final canFinish = data.data?.canFinishAssessment ?? false;
        if (baseState != null) {
          emit(baseState.copyWith(
            visitData: data.data,
            isStarted: isStartedFromApi,
            canFinishAssessment: canFinish,
          ));
        } else {
          emit(VisitDetailsSuccess(
            visitData: data.data,
            customPlanCache: const {},
            isStarted: isStartedFromApi,
            canFinishAssessment: canFinish,
          ));
        }
      case FailureResult(:final failure):
        emit(VisitDetailsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> loadHealthReport(String assessmentId) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess && currentState.healthReport != null) {
      // Already cached
      return;
    }

    emit(const VisitDetailsLoading());

    final result = await _getHealthReportUseCase(assessmentId: assessmentId);

    final baseState = currentState is VisitDetailsSuccess ? currentState : null;

    switch (result) {
      case Success(:final data):
        final healthReport = data.data ?? SpecialistAssessmentHealthReportModel();
        if (baseState != null) {
          emit(baseState.copyWith(healthReport: healthReport));
        } else {
          emit(VisitDetailsSuccess(
            healthReport: healthReport,
            customPlanCache: const {},
          ));
        }
      case FailureResult(:final failure):
        emit(VisitDetailsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<void> loadCustomPlan(String assessmentId, int dayNumber) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      if (currentState.customPlanCache.containsKey(dayNumber)) {
        emit(currentState.copyWith(customPlan: currentState.customPlanCache[dayNumber]));
        return;
      }
    }

    emit(const VisitDetailsLoading());

    final result = await _getCustomPlanUseCase(assessmentId: assessmentId, dayNumber: dayNumber);

    final baseState = currentState is VisitDetailsSuccess ? currentState : null;

    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          final newCache = baseState != null
              ? Map<int, SpecialistAssessmentCustomPlanModel>.from(baseState.customPlanCache)
              : <int, SpecialistAssessmentCustomPlanModel>{};
          newCache[dayNumber] = data.data!;

          if (baseState != null) {
            emit(baseState.copyWith(
              customPlan: data.data,
              customPlanCache: newCache,
              canFinishAssessment: data.data?.canFinishAssessment ?? baseState.canFinishAssessment,
            ));
          } else {
            emit(VisitDetailsSuccess(
              customPlan: data.data,
              customPlanCache: newCache,
              canFinishAssessment: data.data?.canFinishAssessment ?? false,
            ));
          }
        } else {
          emit(const VisitDetailsFailure('خطأ في جلب الخطة'));
        }
      case FailureResult(:final failure):
        emit(VisitDetailsFailure(failure.message, error: AppError.from(failure)));
    }
  }

  Future<(bool, String)> startVisit(String assessmentId) async {
    final currentState = state;
    final prevSuccess = currentState is VisitDetailsSuccess ? currentState : null;

    if (prevSuccess != null) {
      emit(prevSuccess.copyWith(isStarting: true));
    }

    final result = await _startVisitUseCase(assessmentId: assessmentId);

    switch (result) {
      case Success(:final data):
        final isStartedFromApi = data.data?.isStarted ?? true;
        if (prevSuccess != null) {
          final updatedVisitData = prevSuccess.visitData?.copyWith(
            currentState: AssessmentCurrentState.inProgress,
            isStarted: isStartedFromApi,
          );
          emit(prevSuccess.copyWith(
            isStarting: false,
            isStarted: isStartedFromApi,
            visitData: updatedVisitData,
          ));
        } else {
          emit(VisitDetailsSuccess(
            customPlanCache: const {},
            isStarted: isStartedFromApi,
          ));
        }
        return (true, data.message ?? '');
      case FailureResult(:final failure):
        if (prevSuccess != null) {
          emit(prevSuccess.copyWith(isStarting: false));
        }
        return (false, failure.message);
    }
  }

  Future<(bool, String)> finishVisit(String assessmentId) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _repository.finishVisit(assessmentId: assessmentId);

      switch (result) {
        case Success(:final data):
          emit(currentState.copyWith(
            isStarting: false,
            canFinishAssessment: !(data.data?.isFinished ?? true),
          ));
          return (true, data.message);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          return (false, failure.message);
      }
    }
    return (false, '');
  }

  Future<(bool, String)> updateGoal(String assessmentId, String goal) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _updateGoalUseCase(assessmentId: assessmentId, goal: goal);

      switch (result) {
        case Success(:final data):
          final updatedVisitData = currentState.visitData?.copyWith(
            goal: data.data?.goal ?? goal,
          );
          emit(currentState.copyWith(
            isStarting: false,
            visitData: updatedVisitData,
          ));
          return (true, data.message);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          return (false, failure.message);
      }
    }
    return (false, '');
  }

  /// Saves the specialist's notes about the client for this visit.
  ///
  /// Deliberately does not touch `canFinishAssessment`: notes are optional on
  /// the server too, so writing them can never be what unlocks finishing.
  Future<(bool, String)> updateClientNotes(String assessmentId, String clientNotes) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _updateClientNotesUseCase(
        assessmentId: assessmentId,
        clientNotes: clientNotes,
      );

      switch (result) {
        case Success(:final data):
          final updatedVisitData = currentState.visitData?.copyWith(
            clientNotes: data.data?.clientNotes ?? clientNotes,
          );
          emit(currentState.copyWith(
            isStarting: false,
            visitData: updatedVisitData,
          ));
          return (true, data.message);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          return (false, failure.message);
      }
    }
    return (false, '');
  }

  Future<(bool, String, String?)> updateHealthReport({
    required String assessmentId,
    required double weight,
    required double height,
    required double bmi,
    required double bmr,
    required double fatWeight,
    required double fatPercentage,
    required double muscleWeight,
    required double musclePercentage,
    required double protein,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _updateHealthReportUseCase(
        assessmentId: assessmentId,
        weight: weight,
        height: height,
        bmi: bmi,
        bmr: bmr,
        fatWeight: fatWeight,
        fatPercentage: fatPercentage,
        muscleWeight: muscleWeight,
        musclePercentage: musclePercentage,
        protein: protein,
      );

      switch (result) {
        case Success(:final data):
          emit(currentState.copyWith(
            isStarting: false,
            healthReport: data.data?.healthReport,
          ));
          return (true, data.message, null);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          final key = failure is ValidationFailure ? failure.key : null;
          return (false, failure.message, key);
      }
    }
    return (false, '', null);
  }

  Future<(bool, String)> updateCustomPlan({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _updateCustomPlanUseCase(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        planData: planData,
      );

      switch (result) {
        case Success(:final data):
          final newCache = Map<int, SpecialistAssessmentCustomPlanModel>.from(currentState.customPlanCache);
          if (data.data != null) {
            newCache[dayNumber] = data.data!;
          }
          emit(currentState.copyWith(
            isStarting: false,
            customPlan: data.data,
            customPlanCache: newCache,
          ));
          return (true, data.message);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          return (false, failure.message);
      }
    }
    return (false, '');
  }

  Future<(bool, String)> addMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.addMeal(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        mealCategoryId: mealCategoryId,
        mealTemplateId: mealTemplateId,
        time: time,
        ingredientWeights: ingredientWeights,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  Future<(bool, String)> addWorkout({
    required String assessmentId,
    required int dayNumber,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.addWorkout(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        restDuration: restDuration,
        time: time,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  Future<(bool, String)> addActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityId,
    required int goal,
    required String time,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.addActivity(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityId: activityId,
        goal: goal,
        time: time,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  Future<(bool, String)> updateMeal({
    required String assessmentId,
    required int dayNumber,
    required String mealId,
    required String mealCategoryId,
    required String mealTemplateId,
    required String time,
    required List<Map<String, dynamic>> ingredientWeights,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.updateMeal(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        mealId: mealId,
        mealCategoryId: mealCategoryId,
        mealTemplateId: mealTemplateId,
        time: time,
        ingredientWeights: ingredientWeights,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  Future<(bool, String)> updateWorkout({
    required String assessmentId,
    required int dayNumber,
    required String workoutItemId,
    required String exerciseId,
    required int sets,
    required int reps,
    required int restDuration,
    required String time,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.updateWorkout(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        workoutItemId: workoutItemId,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        restDuration: restDuration,
        time: time,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  Future<(bool, String)> updateActivity({
    required String assessmentId,
    required int dayNumber,
    required String activityItemId,
    required String activityId,
    required int goal,
    required String time,
  }) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));
      final result = await _repository.updateActivity(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
        activityItemId: activityItemId,
        activityId: activityId,
        goal: goal,
        time: time,
      );
      return _handlePlanResult(result, dayNumber, currentState);
    }
    return (false, '');
  }

  /// Applies one week of a program onto every day of the visit.
  ///
  /// Unlike the add/update calls, this rewrites **all seven days**, so the
  /// per-day plan cache is rebuilt from scratch rather than patched: leaving a
  /// stale day in it would show the specialist the old plan the moment they
  /// tapped another day tab.
  ///
  /// The client's progress on the previous plan is gone — deliberately, see
  /// ApplyProgramToAssessmentUseCase on the backend. The caller is responsible
  /// for confirming that with the specialist before getting here.
  Future<(bool, String)> applyProgram({
    required String assessmentId,
    required String programId,
    required int weekNumber,
    required int currentDayNumber,
  }) async {
    final currentState = state;
    if (currentState is! VisitDetailsSuccess) return (false, '');

    emit(currentState.copyWith(isStarting: true));

    final result = await _repository.applyProgram(
      assessmentId: assessmentId,
      programId: programId,
      weekNumber: weekNumber,
    );

    switch (result) {
      case Success(:final data):
        final days = data.data?.days ?? const <SpecialistAssessmentCustomPlanModel>[];

        final newCache = <int, SpecialistAssessmentCustomPlanModel>{
          for (final day in days) day.dayNumber: day,
        };

        final planState = data.data?.currentState;
        final canFinish = days.isNotEmpty && days.first.canFinishAssessment;

        emit(currentState.copyWith(
          isStarting: false,
          customPlan: newCache[currentDayNumber] ?? currentState.customPlan,
          customPlanCache: newCache,
          visitData: currentState.visitData?.copyWith(
            currentState: planState ?? currentState.visitData?.currentState,
          ),
          canFinishAssessment: canFinish,
        ));
        return (true, data.message);
      case FailureResult(:final failure):
        emit(currentState.copyWith(isStarting: false));
        return (false, failure.message);
    }
  }

  (bool, String) _handlePlanResult(
    ApiResult<SpecialistAssessmentCustomPlanResponseModel> result,
    int dayNumber,
    VisitDetailsSuccess currentState,
  ) {
    switch (result) {
      case Success(:final data):
        final newCache = Map<int, SpecialistAssessmentCustomPlanModel>.from(currentState.customPlanCache);
        if (data.data != null) {
          newCache[dayNumber] = data.data!;
        }

        final planState = data.data?.currentState;
        final canFinish = data.data?.canFinishAssessment ?? currentState.canFinishAssessment;

        final updatedVisitData = currentState.visitData?.copyWith(
          currentState: planState ?? (canFinish ? AssessmentCurrentState.readyToFinish : currentState.visitData?.currentState),
        );

        emit(currentState.copyWith(
          isStarting: false,
          customPlan: data.data,
          customPlanCache: newCache,
          visitData: updatedVisitData,
          canFinishAssessment: canFinish,
        ));
        return (true, data.message);
      case FailureResult(:final failure):
        emit(currentState.copyWith(isStarting: false));
        return (false, failure.message);
    }
  }
}
