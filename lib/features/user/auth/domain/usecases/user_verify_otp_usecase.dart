import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class UserVerifyOtpUseCase {
  final UserAuthRepository _repository;

  UserVerifyOtpUseCase(this._repository);

  Future<ApiResult<UserVerifyOtpResponseModel>> call(UserVerifyOtpRequest request) {
    return _repository.verifyOtp(request);
  }
}
