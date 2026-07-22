import 'package:dio/dio.dart';
import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/profile/data/models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileResponseModel> getUserProfile();

  Future<UserProfileUpdateResponseModel> updateUserProfile({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  });

  Future<UserProfileDataModel> toggleNotifications();

  Future<UserProfileDataModel> updateLang(String lang);

  /// Returns the API's own success message.
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  });

  Future<ChangePhoneOtpResponse> requestChangePhoneOtp(String phone);

  /// Returns the API's own success message.
  Future<String> verifyChangePhoneOtp({
    required String changePhoneToken,
    required String otp,
  });

  Future<void> signout();
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final ApiService _apiService;

  UserProfileRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserProfileResponseModel> getUserProfile() async {
    final response = await _apiService.get(ApiEndpoints.usersProfile);
    return UserProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfileUpdateResponseModel> updateUserProfile({
    String? fullName,
    String? goalId,
    String? weight,
    String? height,
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      if (fullName != null) 'fullName': fullName,
      if (goalId != null) 'goal': goalId,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (avatarPath != null)
        'avatar': await MultipartFile.fromFile(
          avatarPath,
          filename: avatarPath.split('/').last,
        ),
    });

    final response = await _apiService.patch(
      ApiEndpoints.updateUsersProfile,
      data: formData,
    );
    return UserProfileUpdateResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProfileDataModel> toggleNotifications() async {
    final response = await _apiService.patch(ApiEndpoints.usersNotificationsToggle);
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
    return UserProfileDataModel.fromJson(data);
  }

  @override
  Future<UserProfileDataModel> updateLang(String lang) async {
    final response = await _apiService.patch(
      ApiEndpoints.usersLang,
      data: {'lang': lang},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
    return UserProfileDataModel.fromJson(data);
  }

  @override
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await _apiService.patch(
      ApiEndpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      },
    );
    return (response.data as Map<String, dynamic>)['message'] as String? ?? '';
  }

  @override
  Future<ChangePhoneOtpResponse> requestChangePhoneOtp(String phone) async {
    final response = await _apiService.post(
      ApiEndpoints.changePhoneRequestOtp,
      data: {'phone': phone},
    );
    final json = response.data as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ChangePhoneOtpResponse(
      changePhoneToken: data['changePhoneToken'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  @override
  Future<String> verifyChangePhoneOtp({
    required String changePhoneToken,
    required String otp,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.changePhoneVerifyOtp,
      data: {
        'changePhoneToken': changePhoneToken,
        'otp': otp,
      },
    );
    return (response.data as Map<String, dynamic>)['message'] as String? ?? '';
  }

  @override
  Future<void> signout() async {
    await _apiService.post(ApiEndpoints.userSignout);
  }
}
