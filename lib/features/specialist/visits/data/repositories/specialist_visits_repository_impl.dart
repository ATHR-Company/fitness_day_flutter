import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/datasources/specialist_visits_remote_datasource.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class SpecialistVisitsRepositoryImpl implements SpecialistVisitsRepository {
  final SpecialistVisitsRemoteDataSource remoteDataSource;

  SpecialistVisitsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistAssessmentHistoryResponseModel>> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getAssessmentHistory(
        type: type,
        page: page,
        limit: limit,
        search: search,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentVisitDataResponseModel>> getVisitData({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.getVisitData(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentHealthReportResponseModel>> getHealthReport({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.getHealthReport(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  }) async {
    try {
      final response = await remoteDataSource.getCustomPlan(
        assessmentId: assessmentId,
        dayNumber: dayNumber,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistStartVisitResponseModel>> startVisit({
    required String assessmentId,
  }) async {
    try {
      final response = await remoteDataSource.startVisit(assessmentId: assessmentId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistUpdateGoalResponseModel>> updateGoal({
    required String assessmentId,
    required String goal,
  }) async {
    try {
      final response = await remoteDataSource.updateGoal(
        assessmentId: assessmentId,
        goal: goal,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
