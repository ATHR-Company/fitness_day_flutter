import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class ToggleUserNotificationsUseCase {
  final UserProfileRepository repository;

  ToggleUserNotificationsUseCase(this.repository);

  Future<ApiResult<UserProfileDataModel>> call() {
    return repository.toggleNotifications();
  }
}
