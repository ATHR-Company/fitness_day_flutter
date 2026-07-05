import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class SocialAuthUseCase {
  final UserAuthRepository _repository;

  SocialAuthUseCase(this._repository);

  Future<ApiResult<UserVerifyOtpResponseModel>> call(SocialAuthRequest request) {
    return _repository.socialAuth(request);
  }
}
