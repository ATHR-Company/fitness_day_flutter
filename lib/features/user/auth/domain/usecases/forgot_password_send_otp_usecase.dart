import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class ForgotPasswordSendOtpUseCase {
  final UserAuthRepository _repository;

  ForgotPasswordSendOtpUseCase(this._repository);

  Future<ApiResult<ForgotPasswordTokenResponseModel>> call(ForgotPasswordSendOtpRequest request) {
    return _repository.sendForgotPasswordOtp(request);
  }
}
