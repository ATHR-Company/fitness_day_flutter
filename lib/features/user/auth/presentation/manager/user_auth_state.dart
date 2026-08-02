import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/core/errors/app_error.dart';

sealed class UserAuthState {
  const UserAuthState();
}

class UserAuthInitial extends UserAuthState {
  const UserAuthInitial();
}

class UserAuthLoading extends UserAuthState {
  const UserAuthLoading();
}

class UserSignupSuccess extends UserAuthState {
  final UserSignupResponseModel response;
  const UserSignupSuccess(this.response);
}

class UserVerifyOtpSuccess extends UserAuthState {
  final UserVerifyOtpResponseModel response;
  const UserVerifyOtpSuccess(this.response);
}

class UserSigninSuccess extends UserAuthState {
  final UserSigninResponseModel response;
  const UserSigninSuccess(this.response);
}

class ForgotPasswordSendOtpSuccess extends UserAuthState {
  final ForgotPasswordTokenResponseModel response;
  const ForgotPasswordSendOtpSuccess(this.response);
}

class ForgotPasswordVerifyOtpSuccess extends UserAuthState {
  final ForgotPasswordTokenResponseModel response;
  const ForgotPasswordVerifyOtpSuccess(this.response);
}

class ForgotPasswordResetSuccess extends UserAuthState {
  final ForgotPasswordResetResponseModel response;
  const ForgotPasswordResetSuccess(this.response);
}

class ForgotPasswordResendOtpSuccess extends UserAuthState {
  final ForgotPasswordTokenResponseModel response;
  const ForgotPasswordResendOtpSuccess(this.response);
}

class UserAuthFailure extends UserAuthState {
  final String message;

  /// Typed form of the failure, so the screen can decide between a
  /// full-screen retry and a message. Null on states not yet migrated.
  final AppError? error;
  const UserAuthFailure(this.message, {this.error});
}
