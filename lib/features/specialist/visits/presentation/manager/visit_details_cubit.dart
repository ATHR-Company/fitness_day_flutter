import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_visit_data_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/start_visit_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_goal_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/update_custom_plan_usecase.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';
import 'visit_details_state.dart';

class VisitDetailsCubit extends Cubit<VisitDetailsState> {
  final GetVisitDataUseCase _getVisitDataUseCase;
  final GetHealthReportUseCase _getHealthReportUseCase;
  final GetCustomPlanUseCase _getCustomPlanUseCase;
  final StartVisitUseCase _startVisitUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final UpdateHealthReportUseCase _updateHealthReportUseCase;
  final SpecialistVisitsRepository _repository;

  VisitDetailsCubit(
    this._getVisitDataUseCase,
    this._getHealthReportUseCase,
    this._getCustomPlanUseCase,
    this._startVisitUseCase,
    this._updateGoalUseCase,
    this._updateHealthReportUseCase,
    this._updateCustomPlanUseCase,
    this._repository,
  ) : super(const VisitDetailsInitial());

  final UpdateCustomPlanUseCase _updateCustomPlanUseCase;

  Future<void> loadVisitData(String assessmentId) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess && currentState.visitData != null) {
      // Already cached
      return;
    }

    emit(const VisitDetailsLoading());

    final result = await _getVisitDataUseCase(assessmentId: assessmentId);

    switch (result) {
      case Success(:final data):
        final isStartedFromApi = data.data?.isStarted ?? false;
        final canFinish = data.data?.canFinishAssessment ?? false;
        if (state is VisitDetailsSuccess) {
          emit((state as VisitDetailsSuccess).copyWith(
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
        emit(VisitDetailsFailure(failure.message));
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

    switch (result) {
      case Success(:final data):
        if (state is VisitDetailsSuccess) {
          emit((state as VisitDetailsSuccess).copyWith(healthReport: data.data));
        } else {
          emit(VisitDetailsSuccess(
            healthReport: data.data,
            customPlanCache: const {},
          ));
        }
      case FailureResult(:final failure):
        emit(VisitDetailsFailure(failure.message));
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

    switch (result) {
      case Success(:final data):
        if (data.data != null) {
          final newCache = state is VisitDetailsSuccess
              ? Map<int, dynamic>.from((state as VisitDetailsSuccess).customPlanCache)
              : <int, dynamic>{};
          newCache[dayNumber] = data.data;

          if (state is VisitDetailsSuccess) {
            emit((state as VisitDetailsSuccess).copyWith(
              customPlan: data.data,
              customPlanCache: newCache.cast<int, dynamic>().map((k, v) => MapEntry(k, v)),
            ));
          } else {
            emit(VisitDetailsSuccess(
              customPlan: data.data,
              customPlanCache: newCache.cast<int, dynamic>().map((k, v) => MapEntry(k, v)),
            ));
          }
        } else {
          emit(const VisitDetailsFailure('خطأ في جلب الخطة'));
        }
      case FailureResult(:final failure):
        emit(VisitDetailsFailure(failure.message));
    }
  }

  Future<bool> startVisit(String assessmentId) async {
    final currentState = state;
    if (currentState is VisitDetailsSuccess) {
      emit(currentState.copyWith(isStarting: true));

      final result = await _startVisitUseCase(assessmentId: assessmentId);

      switch (result) {
        case Success(:final data):
          emit(currentState.copyWith(
            isStarting: false,
            isStarted: data.data?.isStarted ?? true,
          ));
          return true;
        case FailureResult():
          emit(currentState.copyWith(isStarting: false));
          return false;
      }
    }
    return false;
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

  Future<(bool, String)> updateHealthReport({
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
          return (true, data.message);
        case FailureResult(:final failure):
          emit(currentState.copyWith(isStarting: false));
          return (false, failure.message);
      }
    }
    return (false, '');
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
}
