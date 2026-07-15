import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';

abstract class SpecialistVisitsRemoteDataSource {
  Future<SpecialistAssessmentHistoryResponseModel> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  });

  Future<SpecialistAssessmentVisitDataResponseModel> getVisitData({
    required String assessmentId,
  });

  Future<SpecialistAssessmentHealthReportResponseModel> getHealthReport({
    required String assessmentId,
  });

  Future<SpecialistAssessmentCustomPlanResponseModel> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  });

  Future<SpecialistStartVisitResponseModel> startVisit({
    required String assessmentId,
  });

  Future<SpecialistUpdateGoalResponseModel> updateGoal({
    required String assessmentId,
    required String goal,
  });
}

class SpecialistVisitsRemoteDataSourceImpl implements SpecialistVisitsRemoteDataSource {
  final ApiService _apiService;

  SpecialistVisitsRemoteDataSourceImpl(this._apiService);

  @override
  Future<SpecialistAssessmentHistoryResponseModel> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  }) async {
    final queryParams = {
      'type': type,
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentHistory,
      queryParameters: queryParams,
    );
    return SpecialistAssessmentHistoryResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentVisitDataResponseModel> getVisitData({
    required String assessmentId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'VISIT_DATA',
      },
    );
    return SpecialistAssessmentVisitDataResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentHealthReportResponseModel> getHealthReport({
    required String assessmentId,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'HEALTH_REPORT',
      },
    );
    return SpecialistAssessmentHealthReportResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistAssessmentCustomPlanResponseModel> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.specialistAssessmentDetails(assessmentId),
      queryParameters: {
        'type': 'CUSTOM_PLAN',
        'dayNumber': dayNumber,
      },
    );
    return SpecialistAssessmentCustomPlanResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistStartVisitResponseModel> startVisit({
    required String assessmentId,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.startSpecialistAssessment(assessmentId),
    );
    return SpecialistStartVisitResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SpecialistUpdateGoalResponseModel> updateGoal({
    required String assessmentId,
    required String goal,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.updateSpecialistAssessmentGoal(assessmentId),
      data: {
        'goal': goal,
      },
    );
    return SpecialistUpdateGoalResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
