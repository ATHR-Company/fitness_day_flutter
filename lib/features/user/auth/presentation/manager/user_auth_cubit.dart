import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/cache/secure_cache.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signup_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_verify_otp_usecase.dart';
import 'user_auth_state.dart';

class UserAuthCubit extends Cubit<UserAuthState> {
  final UserSignupUseCase _signupUseCase;
  final UserVerifyOtpUseCase _verifyOtpUseCase;
  final SecureCache _secureCache;
  final AppCache _appCache;

  UserAuthCubit({
    required UserSignupUseCase signupUseCase,
    required UserVerifyOtpUseCase verifyOtpUseCase,
    required SecureCache secureCache,
    required AppCache appCache,
  })  : _signupUseCase = signupUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _secureCache = secureCache,
        _appCache = appCache,
        super(const UserAuthInitial());

  Future<void> signup(UserSignupRequest request) async {
    emit(const UserAuthLoading());
    final result = await _signupUseCase(request);
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
}
