import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class UserSignupUseCase {
  final UserAuthRepository _repository;

  UserSignupUseCase(this._repository);

  Future<ApiResult<UserSignupResponseModel>> call(UserSignupRequest request) {
    return _repository.signup(request);
  }
}
