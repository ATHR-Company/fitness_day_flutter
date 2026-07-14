import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';
import 'package:fitness_day/features/specialist/profile/domain/repositories/specialist_profile_repository.dart';

class GetSpecialistProfileUseCase {
  final SpecialistProfileRepository repository;

  GetSpecialistProfileUseCase(this.repository);

  Future<ApiResult<SpecialistProfileResponseModel>> call() {
    return repository.getSpecialistProfile();
  }
}
