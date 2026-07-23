import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class DeleteAccountUseCase {
  final UserProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<ApiResult<String>> call() {
    return repository.deleteAccount();
  }
}
