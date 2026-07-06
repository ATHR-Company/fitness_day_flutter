class ForgotPasswordSendOtpRequest {
  final String phone;

  const ForgotPasswordSendOtpRequest({
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
    };
  }
}

class ForgotPasswordVerifyOtpRequest {
  final String resetToken;
  final String otp;

  const ForgotPasswordVerifyOtpRequest({
    required this.resetToken,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetToken': resetToken,
      'otp': otp,
    };
  }
}

class ForgotPasswordResetRequest {
  final String resetToken;
  final String password;
  final String passwordConfirm;

  const ForgotPasswordResetRequest({
    required this.resetToken,
    required this.password,
    required this.passwordConfirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetToken': resetToken,
      'password': password,
      'passwordConfirm': passwordConfirm,
    };
  }
}

class ForgotPasswordResendOtpRequest {
  final String resetToken;

  const ForgotPasswordResendOtpRequest({
    required this.resetToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetToken': resetToken,
    };
  }
}

class ForgotPasswordTokenResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final String resetToken;

  const ForgotPasswordTokenResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.resetToken,
  });

  factory ForgotPasswordTokenResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ForgotPasswordTokenResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      resetToken: data['resetToken'] as String,
    );
  }
}

class ForgotPasswordResetResponseModel {
  final bool success;
  final int statusCode;
  final String message;

  const ForgotPasswordResetResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory ForgotPasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResetResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
    );
  }
}
