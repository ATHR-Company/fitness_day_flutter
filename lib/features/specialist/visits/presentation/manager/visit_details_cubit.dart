import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_visit_data_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_health_report_usecase.dart';
import 'package:fitness_day/features/specialist/visits/domain/usecases/get_custom_plan_usecase.dart';
import 'visit_details_state.dart';

class VisitDetailsCubit extends Cubit<VisitDetailsState> {
  final GetVisitDataUseCase _getVisitDataUseCase;
  final GetHealthReportUseCase _getHealthReportUseCase;
  final GetCustomPlanUseCase _getCustomPlanUseCase;

  VisitDetailsCubit(
    this._getVisitDataUseCase,
    this._getHealthReportUseCase,
    this._getCustomPlanUseCase,
  ) : super(const VisitDetailsInitial());

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
        if (state is VisitDetailsSuccess) {
          emit((state as VisitDetailsSuccess).copyWith(visitData: data.data));
        } else {
          emit(VisitDetailsSuccess(
            visitData: data.data,
            customPlanCache: const {},
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
}
