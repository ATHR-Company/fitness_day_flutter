import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class ForgotPasswordResendOtpUseCase {
  final UserAuthRepository _repository;

  ForgotPasswordResendOtpUseCase(this._repository);

  Future<ApiResult<ForgotPasswordTokenResponseModel>> call(ForgotPasswordResendOtpRequest request) {
    return _repository.resendForgotPasswordOtp(request);
  }
}
