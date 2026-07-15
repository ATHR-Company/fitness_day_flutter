import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class GetVisitDataUseCase {
  final SpecialistVisitsRepository repository;

  GetVisitDataUseCase(this.repository);

  Future<ApiResult<SpecialistAssessmentVisitDataResponseModel>> call({
    required String assessmentId,
  }) {
    return repository.getVisitData(assessmentId: assessmentId);
  }
}
