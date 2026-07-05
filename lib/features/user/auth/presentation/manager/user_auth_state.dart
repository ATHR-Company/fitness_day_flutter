import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';

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

class UserAuthFailure extends UserAuthState {
  final String message;
  const UserAuthFailure(this.message);
}
