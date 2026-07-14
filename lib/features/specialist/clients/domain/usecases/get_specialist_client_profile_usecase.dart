import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/specialist_client_model.dart';
import 'package:fitness_day/features/specialist/clients/domain/repositories/specialist_clients_repository.dart';

class GetSpecialistClientProfileUseCase {
  final SpecialistClientsRepository repository;

  GetSpecialistClientProfileUseCase(this.repository);

  Future<ApiResult<SpecialistClientProfileResponseModel>> call({
    required String userId,
  }) {
    return repository.getSpecialistClientProfile(
      userId: userId,
    );
  }
}
