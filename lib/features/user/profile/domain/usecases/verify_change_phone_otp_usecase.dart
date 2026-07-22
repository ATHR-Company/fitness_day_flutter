import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class VerifyChangePhoneOtpUseCase {
  final UserProfileRepository repository;

  VerifyChangePhoneOtpUseCase(this.repository);

  Future<ApiResult<String>> call({
    required String changePhoneToken,
    required String otp,
  }) {
    return repository.verifyChangePhoneOtp(
      changePhoneToken: changePhoneToken,
      otp: otp,
    );
  }
}
