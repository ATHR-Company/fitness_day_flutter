import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class GetCustomPlanUseCase {
  final SpecialistVisitsRepository repository;

  GetCustomPlanUseCase(this.repository);

  Future<ApiResult<SpecialistAssessmentCustomPlanResponseModel>> call({
    required String assessmentId,
    required int dayNumber,
  }) {
    return repository.getCustomPlan(
      assessmentId: assessmentId,
      dayNumber: dayNumber,
    );
  }
}
