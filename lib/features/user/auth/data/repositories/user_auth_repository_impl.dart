import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/user/auth/data/datasources/user_auth_remote_datasource.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class UserAuthRepositoryImpl implements UserAuthRepository {
  final UserAuthRemoteDataSource _remoteDataSource;

  UserAuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<UserSignupResponseModel>> signup(UserSignupRequest request) async {
    try {
      final response = await _remoteDataSource.signup(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserSignupResponseModel>> resendSignupOtp(
    UserResendOtpRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.resendSignupOtp(request);
      return Success(response);
    } catch (e) {
      // A 429 here becomes a RateLimitFailure carrying `retryAfterSeconds`,
      // which is what the OTP screen counts down from.
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> verifyOtp(UserVerifyOtpRequest request) async {
    try {
      final response = await _remoteDataSource.verifyOtp(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> socialAuth(SocialAuthRequest request) async {
    try {
      final response = await _remoteDataSource.socialAuth(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserSigninResponseModel>> signin(UserSigninRequest request) async {
    try {
      final response = await _remoteDataSource.signin(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> sendForgotPasswordOtp(
    ForgotPasswordSendOtpRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.sendForgotPasswordOtp(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> verifyForgotPasswordOtp(
    ForgotPasswordVerifyOtpRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.verifyForgotPasswordOtp(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ForgotPasswordResetResponseModel>> resetPassword(
    ForgotPasswordResetRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.resetPassword(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> resendForgotPasswordOtp(
    ForgotPasswordResendOtpRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.resendForgotPasswordOtp(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<UserLookupsResponseModel>> getLookups() async {
    try {
      final response = await _remoteDataSource.getLookups();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<HealthQuestionsResponseModel>> getHealthQuestions() async {
    try {
      final response = await _remoteDataSource.getHealthQuestions();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<CompletePersonalDataResponseModel>> completePersonalData(
    CompletePersonalDataRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.completePersonalData(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SubmitHealthAnswersResponseModel>> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  ) async {
    try {
      final response = await _remoteDataSource.submitHealthAnswers(request);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
