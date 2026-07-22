import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/network/device_type_helper.dart';
import 'package:fitness_day/core/network/fcm_helper.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signup_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/social_auth_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signin_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_send_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_reset_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/forgot_password_resend_otp_usecase.dart';
import 'user_auth_state.dart';

class UserAuthCubit extends Cubit<UserAuthState> {
  final UserSignupUseCase _signupUseCase;
  final UserVerifyOtpUseCase _verifyOtpUseCase;
  final SocialAuthUseCase _socialAuthUseCase;
  final UserSigninUseCase _signinUseCase;
  final ForgotPasswordSendOtpUseCase _forgotPasswordSendOtpUseCase;
  final ForgotPasswordVerifyOtpUseCase _forgotPasswordVerifyOtpUseCase;
  final ForgotPasswordResetUseCase _forgotPasswordResetUseCase;
  final ForgotPasswordResendOtpUseCase _forgotPasswordResendOtpUseCase;
  final SecureCache _secureCache;
  final AppCache _appCache;

  UserAuthCubit({
    required UserSignupUseCase signupUseCase,
    required UserVerifyOtpUseCase verifyOtpUseCase,
    required SocialAuthUseCase socialAuthUseCase,
    required UserSigninUseCase signinUseCase,
    required ForgotPasswordSendOtpUseCase forgotPasswordSendOtpUseCase,
    required ForgotPasswordVerifyOtpUseCase forgotPasswordVerifyOtpUseCase,
    required ForgotPasswordResetUseCase forgotPasswordResetUseCase,
    required ForgotPasswordResendOtpUseCase forgotPasswordResendOtpUseCase,
    required SecureCache secureCache,
    required AppCache appCache,
  })  : _signupUseCase = signupUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _socialAuthUseCase = socialAuthUseCase,
        _signinUseCase = signinUseCase,
        _forgotPasswordSendOtpUseCase = forgotPasswordSendOtpUseCase,
        _forgotPasswordVerifyOtpUseCase = forgotPasswordVerifyOtpUseCase,
        _forgotPasswordResetUseCase = forgotPasswordResetUseCase,
        _forgotPasswordResendOtpUseCase = forgotPasswordResendOtpUseCase,
        _secureCache = secureCache,
        _appCache = appCache,
        super(const UserAuthInitial());

  Future<void> signup(UserSignupRequest request) async {
    emit(const UserAuthLoading());
    final actualFcmToken = await FcmHelper.getToken();
    final updatedRequest = UserSignupRequest(
      phone: request.phone,
      password: request.password,
      passwordConfirm: request.passwordConfirm,
      fcmToken: actualFcmToken,
      deviceType: request.deviceType,
    );

    final result = await _signupUseCase(updatedRequest);
    switch (result) {
      case Success(:final data):
        emit(UserSignupSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> verifyOtp(UserVerifyOtpRequest request) async {
    emit(const UserAuthLoading());
    final result = await _verifyOtpUseCase(request);
    switch (result) {
      case Success(:final data):
        await _secureCache.saveToken(data.accessToken);
        await _secureCache.saveRefreshToken(data.refreshToken);
        await _appCache.saveUserType('user');
        // Only mark the session as "logged in" (so splash auto-resumes to
        // home) once the user has actually finished onboarding. Otherwise,
        // closing the app mid-signup lands back on role selection next time.
        if (data.isPersonalDataComplete && data.isSurveyComplete) {
          await _appCache.saveIsLoggedIn(true);
        }
        // Ensure cached user structure is initialized
        final currentUser = _appCache.getUser();
        await _appCache.saveUser(currentUser);
        emit(UserVerifyOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> socialAuth({
    required String provider,
    required String idToken,
  }) async {
    emit(const UserAuthLoading());
    final actualFcmToken = await FcmHelper.getToken();
    final request = SocialAuthRequest(
      idToken: idToken,
      provider: provider,
      fcmToken: actualFcmToken,
      deviceType: DeviceTypeHelper.current,
    );
    final result = await _socialAuthUseCase(request);
    switch (result) {
      case Success(:final data):
        await _secureCache.saveToken(data.accessToken);
        await _secureCache.saveRefreshToken(data.refreshToken);
        await _appCache.saveUserType('user');
        // Only mark the session as "logged in" (so splash auto-resumes to
        // home) once the user has actually finished onboarding. Otherwise,
        // closing the app mid-signup lands back on role selection next time.
        if (data.isPersonalDataComplete && data.isSurveyComplete) {
          await _appCache.saveIsLoggedIn(true);
        }
        // Ensure cached user structure is initialized
        final currentUser = _appCache.getUser();
        await _appCache.saveUser(currentUser);
        emit(UserVerifyOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> signin(UserSigninRequest request) async {
    emit(const UserAuthLoading());
    final actualFcmToken = await FcmHelper.getToken();
    final updatedRequest = UserSigninRequest(
      phone: request.phone,
      password: request.password,
      fcmToken: actualFcmToken,
      deviceType: request.deviceType,
    );

    final result = await _signinUseCase(updatedRequest);
    switch (result) {
      case Success(:final data):
        await _secureCache.saveToken(data.accessToken);
        await _secureCache.saveRefreshToken(data.refreshToken);
        await _appCache.saveUserType('user');
        if (data.isPersonalDataComplete && data.isSurveyComplete) {
          await _appCache.saveIsLoggedIn(true);
        }
        // Initialize cached user profile and set/override phone number
        final currentUser = _appCache.getUser();
        await _appCache.saveUser(currentUser.copyWith(phone: request.phone));
        emit(UserSigninSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> sendForgotPasswordOtp(String phone) async {
    emit(const UserAuthLoading());
    final result = await _forgotPasswordSendOtpUseCase(
      ForgotPasswordSendOtpRequest(phone: phone),
    );
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordSendOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> verifyForgotPasswordOtp(String resetToken, String otp) async {
    emit(const UserAuthLoading());
    final result = await _forgotPasswordVerifyOtpUseCase(
      ForgotPasswordVerifyOtpRequest(resetToken: resetToken, otp: otp),
    );
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordVerifyOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> resetPassword(
    String resetToken,
    String password,
    String passwordConfirm,
  ) async {
    emit(const UserAuthLoading());
    final result = await _forgotPasswordResetUseCase(
      ForgotPasswordResetRequest(
        resetToken: resetToken,
        password: password,
        passwordConfirm: passwordConfirm,
      ),
    );
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordResetSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }

  Future<void> resendForgotPasswordOtp(String resetToken) async {
    emit(const UserAuthLoading());
    final result = await _forgotPasswordResendOtpUseCase(
      ForgotPasswordResendOtpRequest(resetToken: resetToken),
    );
    switch (result) {
      case Success(:final data):
        emit(ForgotPasswordResendOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }
}
