import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class ForgotPasswordResetUseCase {
  final UserAuthRepository _repository;

  ForgotPasswordResetUseCase(this._repository);

  Future<ApiResult<ForgotPasswordResetResponseModel>> call(ForgotPasswordResetRequest request) {
    return _repository.resetPassword(request);
  }
}
