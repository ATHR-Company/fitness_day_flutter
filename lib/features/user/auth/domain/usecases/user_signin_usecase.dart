import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class UserSigninUseCase {
  final UserAuthRepository _repository;

  UserSigninUseCase(this._repository);

  Future<ApiResult<UserSigninResponseModel>> call(UserSigninRequest request) {
    return _repository.signin(request);
  }
}
