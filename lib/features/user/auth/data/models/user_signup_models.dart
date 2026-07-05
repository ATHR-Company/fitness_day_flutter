class UserSignupRequest {
  final String phone;
  final String password;
  final String passwordConfirm;
  final String fcmToken;
  final String deviceType;

  const UserSignupRequest({
    required this.phone,
    required this.password,
    required this.passwordConfirm,
    required this.fcmToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
    };
  }
}

class UserSignupResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final String signupToken;
  final bool isResend;

  const UserSignupResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.signupToken,
    required this.isResend,
  });

  factory UserSignupResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UserSignupResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      signupToken: data['signupToken'] as String,
      isResend: data['isResend'] as bool? ?? false,
    );
  }
}
