class UserSigninRequest {
  final String phone;
  final String password;
  final String fcmToken;
  final String deviceType;

  const UserSigninRequest({
    required this.phone,
    required this.password,
    required this.fcmToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
    };
  }
}

class UserSigninResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final String accessToken;
  final String refreshToken;
  final bool isPersonalDataComplete;
  final bool isSurveyComplete;

  const UserSigninResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.isPersonalDataComplete,
    required this.isSurveyComplete,
  });

  factory UserSigninResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final completionStatus = data['completionStatus'] as Map<String, dynamic>;
    return UserSigninResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      isPersonalDataComplete: completionStatus['isPersonalDataComplete'] as bool? ?? false,
      isSurveyComplete: completionStatus['isSurveyComplete'] as bool? ?? false,
    );
  }
}
