import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/failures.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_signup_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/user_verify_otp_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/social_auth_usecase.dart';

class FakeUserAuthRepository implements UserAuthRepository {
  bool shouldSucceed = true;

  @override
  Future<ApiResult<UserSignupResponseModel>> signup(UserSignupRequest request) async {
    if (shouldSucceed) {
      return const Success(UserSignupResponseModel(
        success: true,
        statusCode: 201,
        message: 'تم ارسال الرمز بنجاح.',
        signupToken: 'token-123',
        isResend: false,
      ));
    } else {
      return const FailureResult(ServerFailure('Signup failed'));
    }
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> verifyOtp(UserVerifyOtpRequest request) async {
    if (shouldSucceed) {
      return const Success(UserVerifyOtpResponseModel(
        success: true,
        statusCode: 200,
        message: 'تم التحقق من رمز التحقق بنجاح.',
        accessToken: 'access-123',
        refreshToken: 'refresh-123',
        isPersonalDataComplete: false,
        isSurveyComplete: false,
      ));
    } else {
      return const FailureResult(ServerFailure('Verify failed'));
    }
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> socialAuth(SocialAuthRequest request) async {
    if (shouldSucceed) {
      return const Success(UserVerifyOtpResponseModel(
        success: true,
        statusCode: 200,
        message: 'تم تسجيل الدخول بنجاح.',
        accessToken: 'access-social',
        refreshToken: 'refresh-social',
        isPersonalDataComplete: false,
        isSurveyComplete: false,
      ));
    } else {
      return const FailureResult(ServerFailure('Social login failed'));
    }
  }

  @override
  Future<ApiResult<UserLookupsResponseModel>> getLookups() async {
    if (shouldSucceed) {
      return const Success(UserLookupsResponseModel(
        success: true,
        statusCode: 200,
        message: 'Success',
        goals: [LookupItem(id: '1', type: 'GOAL', name: 'إنقاص الوزن', order: 1)],
        activityLevels: [LookupItem(id: '2', type: 'ACTIVITY_LEVEL', name: 'خامل', order: 1)],
        branches: [LookupItem(id: '3', type: 'BRANCH', name: 'القطيف', order: 1)],
      ));
    } else {
      return const FailureResult(ServerFailure('Lookups failed'));
    }
  }

  @override
  Future<ApiResult<HealthQuestionsResponseModel>> getHealthQuestions() async {
    if (shouldSucceed) {
      return const Success(HealthQuestionsResponseModel(
        success: true,
        statusCode: 200,
        message: 'Success',
        data: [HealthQuestion(id: '1', text: 'Question 1', order: 1)],
      ));
    } else {
      return const FailureResult(ServerFailure('Questions failed'));
    }
  }

  @override
  Future<ApiResult<CompletePersonalDataResponseModel>> completePersonalData(
    CompletePersonalDataRequest request,
  ) async {
    if (shouldSucceed) {
      return const Success(CompletePersonalDataResponseModel(
        success: true,
        statusCode: 200,
        message: 'Success',
        isPersonalDataComplete: true,
        isSurveyComplete: false,
      ));
    } else {
      return const FailureResult(ServerFailure('Personal data failed'));
    }
  }

  @override
  Future<ApiResult<SubmitHealthAnswersResponseModel>> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  ) async {
    if (shouldSucceed) {
      return const Success(SubmitHealthAnswersResponseModel(
        success: true,
        statusCode: 200,
        message: 'Success',
        isPersonalDataComplete: true,
        isSurveyComplete: true,
        isSubscribed: false,
        bodyReport: BodyReportModel(
          bmi: ReportMetric(value: 25.47, status: 'صحي', unit: 'كجم/متر²'),
          idealWeight: ReportMetric(value: 68.0, unit: 'كيلوجرام'),
          calories: ReportMetric(value: 1025.0, unit: 'كالوري'),
          proteinNeeds: ReportMetric(value: 45.0, unit: 'جرام'),
          currentData: CurrentReportData(
            weight: 78.0,
            weightUnit: 'كيلوجرام',
            height: 175.0,
            heightUnit: 'سنتيمتر',
            activityLevel: 'خامل',
            goal: 'إنقاص الوزن',
            branch: 'القطيف',
          ),
        ),
      ));
    } else {
      return const FailureResult(ServerFailure('Submit answers failed'));
    }
  }
}

void main() {
  late FakeUserAuthRepository repository;
  late UserSignupUseCase signupUseCase;
  late UserVerifyOtpUseCase verifyOtpUseCase;
  late SocialAuthUseCase socialAuthUseCase;

  setUp(() {
    repository = FakeUserAuthRepository();
    signupUseCase = UserSignupUseCase(repository);
    verifyOtpUseCase = UserVerifyOtpUseCase(repository);
    socialAuthUseCase = SocialAuthUseCase(repository);
  });

  group('User Signup UseCase Tests', () {
    test('should return Success with response model when repository succeeds', () async {
      // Arrange
      repository.shouldSucceed = true;
      const request = UserSignupRequest(
        phone: '1234567890',
        password: 'password',
        passwordConfirm: 'password',
        fcmToken: 'token',
        deviceType: 'android',
      );

      // Act
      final result = await signupUseCase(request);

      // Assert
      expect(result, isA<Success<UserSignupResponseModel>>());
      final successResult = result as Success<UserSignupResponseModel>;
      expect(successResult.data.signupToken, 'token-123');
      expect(successResult.data.success, true);
    });

    test('should return FailureResult when repository fails', () async {
      // Arrange
      repository.shouldSucceed = false;
      const request = UserSignupRequest(
        phone: '1234567890',
        password: 'password',
        passwordConfirm: 'password',
        fcmToken: 'token',
        deviceType: 'android',
      );

      // Act
      final result = await signupUseCase(request);

      // Assert
      expect(result, isA<FailureResult<UserSignupResponseModel>>());
      final failureResult = result as FailureResult<UserSignupResponseModel>;
      expect(failureResult.failure.message, 'Signup failed');
    });
  });

  group('User Verify OTP UseCase Tests', () {
    test('should return Success with tokens when repository succeeds', () async {
      // Arrange
      repository.shouldSucceed = true;
      const request = UserVerifyOtpRequest(
        signupToken: 'token-123',
        otp: '123456',
      );

      // Act
      final result = await verifyOtpUseCase(request);

      // Assert
      expect(result, isA<Success<UserVerifyOtpResponseModel>>());
      final successResult = result as Success<UserVerifyOtpResponseModel>;
      expect(successResult.data.accessToken, 'access-123');
      expect(successResult.data.refreshToken, 'refresh-123');
    });
  });

  group('Social Auth UseCase Tests', () {
    test('should return Success with tokens when repository succeeds for Apple provider', () async {
      // Arrange
      repository.shouldSucceed = true;
      const request = SocialAuthRequest(
        idToken: 'test_apple_id_token',
        provider: 'APPLE',
        fcmToken: 'fcm-123',
        deviceType: 'android',
      );

      // Act
      final result = await socialAuthUseCase(request);

      // Assert
      expect(result, isA<Success<UserVerifyOtpResponseModel>>());
      final successResult = result as Success<UserVerifyOtpResponseModel>;
      expect(successResult.data.accessToken, 'access-social');
      expect(successResult.data.refreshToken, 'refresh-social');
    });
  });
}
