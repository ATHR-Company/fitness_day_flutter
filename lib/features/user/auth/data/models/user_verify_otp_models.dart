class UserVerifyOtpRequest {
  final String signupToken;
  final String otp;

  const UserVerifyOtpRequest({
    required this.signupToken,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'signupToken': signupToken,
      'otp': otp,
    };
  }
}

class UserVerifyOtpResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final String accessToken;
  final String refreshToken;
  final bool isPersonalDataComplete;
  final bool isSurveyComplete;
  final String type;

  const UserVerifyOtpResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.isPersonalDataComplete,
    required this.isSurveyComplete,
    required this.type,
  });

  factory UserVerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final completionStatus = data['completionStatus'] as Map<String, dynamic>;
    return UserVerifyOtpResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      isPersonalDataComplete: completionStatus['isPersonalDataComplete'] as bool? ?? false,
      isSurveyComplete: completionStatus['isSurveyComplete'] as bool? ?? false,
      type: data['type'] as String? ?? 'user',
    );
  }
}
