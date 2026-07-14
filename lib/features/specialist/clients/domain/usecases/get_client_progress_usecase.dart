import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';

class GetClientProgressUseCase {
  final SpecialistClientsRepository repository;

  GetClientProgressUseCase(this.repository);

  Future<ApiResult<ClientProgressResponseModel>> call({
    required String userId,
    required int visitNumber,
  }) {
    return repository.getClientProgress(userId: userId, visitNumber: visitNumber);
  }
}
