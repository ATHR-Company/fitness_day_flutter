import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

/// Sends the signup verification code again, returning a fresh signup token.
class UserResendOtpUseCase {
  final UserAuthRepository _repository;

  UserResendOtpUseCase(this._repository);

  Future<ApiResult<UserSignupResponseModel>> call(UserResendOtpRequest request) {
    return _repository.resendSignupOtp(request);
  }
}
