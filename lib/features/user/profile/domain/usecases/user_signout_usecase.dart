import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class UserSignoutUseCase {
  final UserProfileRepository repository;

  UserSignoutUseCase(this.repository);

  Future<ApiResult<void>> call() {
    return repository.signout();
  }
}
