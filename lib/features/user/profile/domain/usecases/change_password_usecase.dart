import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class ChangePasswordUseCase {
  final UserProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<ApiResult<String>> call({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }
}
