import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_history_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class GetAssessmentHistoryUseCase {
  final SpecialistVisitsRepository repository;

  GetAssessmentHistoryUseCase(this.repository);

  Future<ApiResult<SpecialistAssessmentHistoryResponseModel>> call({
    required String type,
    required int page,
    required int limit,
    String? search,
  }) {
    return repository.getAssessmentHistory(
      type: type,
      page: page,
      limit: limit,
      search: search,
    );
  }
}
