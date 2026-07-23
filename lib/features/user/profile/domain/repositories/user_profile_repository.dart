import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';

abstract class UserProfileRepository {
  Future<ApiResult<UserProfileResponseModel>> getUserProfile();

  Future<ApiResult<UserProfileUpdateResponseModel>> updateUserProfile({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  });

  Future<ApiResult<UserProfileDataModel>> toggleNotifications();

  Future<ApiResult<UserProfileDataModel>> updateLang(String lang);

  /// Returns the API's own success message.
  Future<ApiResult<String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });

  Future<ApiResult<ChangePhoneOtpResponse>> requestChangePhoneOtp(String phone);

  /// Returns the API's own success message.
  Future<ApiResult<String>> verifyChangePhoneOtp({
    required String changePhoneToken,
    required String otp,
  });

  Future<ApiResult<void>> signout();

  /// Returns the API's own success message.
  Future<ApiResult<String>> deleteAccount();
}
