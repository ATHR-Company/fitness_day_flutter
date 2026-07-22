import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';
import 'package:fitness_day/features/user/profile/domain/repositories/user_profile_repository.dart';

class RequestChangePhoneOtpUseCase {
  final UserProfileRepository repository;

  RequestChangePhoneOtpUseCase(this.repository);

  Future<ApiResult<ChangePhoneOtpResponse>> call(String phone) {
    return repository.requestChangePhoneOtp(phone);
  }
}
