import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/network/fcm_helper.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signup_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/social_auth_usecase.dart';
import 'user_auth_state.dart';

class UserAuthCubit extends Cubit<UserAuthState> {
  final UserSignupUseCase _signupUseCase;
  final UserVerifyOtpUseCase _verifyOtpUseCase;
  final SocialAuthUseCase _socialAuthUseCase;
  final SecureCache _secureCache;
  final AppCache _appCache;

  UserAuthCubit({
    required UserSignupUseCase signupUseCase,
    required UserVerifyOtpUseCase verifyOtpUseCase,
    required SocialAuthUseCase socialAuthUseCase,
    required SecureCache secureCache,
    required AppCache appCache,
  })  : _signupUseCase = signupUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _socialAuthUseCase = socialAuthUseCase,
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
        await _appCache.saveIsLoggedIn(true);
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
      deviceType: 'android',
    );
    final result = await _socialAuthUseCase(request);
    switch (result) {
      case Success(:final data):
        await _secureCache.saveToken(data.accessToken);
        await _secureCache.saveRefreshToken(data.refreshToken);
        await _appCache.saveIsLoggedIn(true);
        emit(UserVerifyOtpSuccess(data));
      case FailureResult(:final failure):
        emit(UserAuthFailure(failure.message));
    }
  }
}
