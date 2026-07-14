import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';

class GetSpecialistClientsUseCase {
  final SpecialistClientsRepository repository;

  GetSpecialistClientsUseCase(this.repository);

  Future<ApiResult<SpecialistClientsListResponseModel>> call({
    required int page,
    required int limit,
    required String status,
    String? search,
  }) {
    return repository.getSpecialistClients(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }
}
