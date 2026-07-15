import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_assessment_model.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';

class GetUpcomingAssessmentsUseCase {
  final SpecialistClientsRepository repository;

  GetUpcomingAssessmentsUseCase(this.repository);

  Future<ApiResult<ClientAssessmentsResponseModel>> call({
    required String userId,
    int page = 1,
    int limit = 10,
  }) {
    return repository.getUpcomingAssessments(userId: userId, page: page, limit: limit);
  }
}
