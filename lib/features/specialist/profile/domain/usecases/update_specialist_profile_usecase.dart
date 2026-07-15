import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';
import 'package:fitness_day/features/specialist/profile/domain/repositories/specialist_profile_repository.dart';

class UpdateSpecialistProfileUseCase {
  final SpecialistProfileRepository repository;

  UpdateSpecialistProfileUseCase(this.repository);

  Future<ApiResult<SpecialistProfileResponseModel>> call({
    required String name,
    String? avatarPath,
  }) {
    return repository.updateSpecialistProfile(
      name: name,
      avatarPath: avatarPath,
    );
  }
}
