import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';

abstract class SpecialistVisitsRepository {
  Future<ApiResult<SpecialistAssessmentHistoryResponseModel>> getAssessmentHistory({
    required String type,
    required int page,
    required int limit,
    String? search,
  });

  Future<ApiResult<SpecialistAssessmentVisitDataResponseModel>> getVisitData({
    required String assessmentId,
  });

  Future<ApiResult<SpecialistAssessmentHealthReportResponseModel>> getHealthReport({
    required String assessmentId,
  });

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> getCustomPlan({
    required String assessmentId,
    required int dayNumber,
  });
}
