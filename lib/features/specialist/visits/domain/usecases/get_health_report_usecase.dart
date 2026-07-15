import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class GetHealthReportUseCase {
  final SpecialistVisitsRepository repository;

  GetHealthReportUseCase(this.repository);

  Future<ApiResult<SpecialistAssessmentHealthReportResponseModel>> call({
    required String assessmentId,
  }) {
    return repository.getHealthReport(assessmentId: assessmentId);
  }
}
