import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class UpdateCustomPlanUseCase {
  final SpecialistVisitsRepository _repository;

  UpdateCustomPlanUseCase(this._repository);

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> call({
    required String assessmentId,
    required int dayNumber,
    required Map<String, dynamic> planData,
  }) {
    return _repository.updateCustomPlan(
      assessmentId: assessmentId,
      dayNumber: dayNumber,
      planData: planData,
    );
  }
}
