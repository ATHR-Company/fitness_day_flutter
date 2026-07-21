import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<ApiResult<UserProfileUpdateResponseModel>> call({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  }) {
    return repository.updateUserProfile(
      fullName: fullName,
      goalId: goalId,
      weight: weight,
      height: height,
      avatarPath: avatarPath,
    );
  }
}
