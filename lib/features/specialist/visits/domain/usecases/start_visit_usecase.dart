import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_start_visit_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class StartVisitUseCase {
  final SpecialistVisitsRepository repository;

  StartVisitUseCase(this.repository);

  Future<ApiResult<SpecialistStartVisitResponseModel>> call({
    required String assessmentId,
  }) {
    return repository.startVisit(assessmentId: assessmentId);
  }
}
