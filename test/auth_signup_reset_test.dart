import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_day/core/cache/app_cache.dart';
import 'package:fitness_day/core/models/user_model.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/forgot_password_models.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_login_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/complete_personal_data_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_health_questions_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/get_user_lookups_usecase.dart';
import 'package:fitness_day/features/user/auth/domain/usecases/submit_health_answers_usecase.dart';
import 'package:fitness_day/features/user/auth/presentation/manager/user_setup_cubit.dart';

class _FakeUserAuthRepository implements UserAuthRepository {
  @override
  Future<ApiResult<UserSignupResponseModel>> signup(UserSignupRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> verifyOtp(UserVerifyOtpRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<UserVerifyOtpResponseModel>> socialAuth(SocialAuthRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<UserSigninResponseModel>> signin(UserSigninRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> sendForgotPasswordOtp(
    ForgotPasswordSendOtpRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> verifyForgotPasswordOtp(
    ForgotPasswordVerifyOtpRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ForgotPasswordResetResponseModel>> resetPassword(
    ForgotPasswordResetRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ForgotPasswordTokenResponseModel>> resendForgotPasswordOtp(
    ForgotPasswordResendOtpRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<UserLookupsResponseModel>> getLookups() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<HealthQuestionsResponseModel>> getHealthQuestions() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<CompletePersonalDataResponseModel>> completePersonalData(
    CompletePersonalDataRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<SubmitHealthAnswersResponseModel>> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  ) {
    throw UnimplementedError();
  }
}

class _FakeAppCache implements AppCache {
  @override
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {}

  @override
  bool isLoggedIn() => false;

  @override
  Future<void> saveHasSeenOnboarding(bool hasSeenOnboarding) async {}

  @override
  bool hasSeenOnboarding() => false;

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  UserModel getUser() => const UserModel(name: '', email: '', phone: '');

  @override
  Future<void> deleteUser() async {}

  @override
  Future<void> saveAssessmentId(String assessmentId) async {}

  @override
  String? getAssessmentId() => null;

  @override
  Future<void> saveUserType(String userType) async {}

  @override
  String getUserType() => 'user';

  @override
  Future<void> saveIsSubscribed(bool isSubscribed) async {}

  @override
  bool getIsSubscribed() => false;

  @override
  Future<void> savePendingPaymentOrderId(String orderIdentity) async {}

  @override
  String? getPendingPaymentOrderId() => null;

  @override
  Future<void> clearPendingPaymentOrderId() async {}

  @override
  Future<void> saveDeviceFallbackId(String id) async {}

  @override
  String? getDeviceFallbackId() => null;

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> clear() async {}
}

void main() {
  group('UserSetupCubit fresh signup reset', () {
    test('resetForNewSignup clears saved onboarding draft values', () {
      final cubit = UserSetupCubit(
        getUserLookupsUseCase: GetUserLookupsUseCase(_FakeUserAuthRepository()),
        completePersonalDataUseCase: CompletePersonalDataUseCase(_FakeUserAuthRepository()),
        getHealthQuestionsUseCase: GetHealthQuestionsUseCase(_FakeUserAuthRepository()),
        submitHealthAnswersUseCase: SubmitHealthAnswersUseCase(_FakeUserAuthRepository()),
        appCache: _FakeAppCache(),
      );

      cubit.savePersonalData(
        fullName: 'Ahmed',
        gender: 'male',
        birthDate: '2024-01-01',
        height: 180,
        weight: 80,
        activityLevelId: 'activity',
        goalId: 'goal',
        branchId: 'branch',
      );
      cubit.saveDietData(
        dietType: 'MIXED',
        dailyMeals: 2,
        preferredFoods: 'Salad',
        dislikedFoods: 'Spicy',
        foodAllergies: 'Peanut',
      );
      cubit.saveFitnessData(
        weeklyWorkouts: 4,
        dailySteps: 10000,
        preferredExercises: 'Running',
        dailyWorkoutHours: 1.5,
      );

      cubit.resetForNewSignup();

      expect(cubit.fullName, isNull);
      expect(cubit.gender, isNull);
      expect(cubit.birthDate, isNull);
      expect(cubit.height, isNull);
      expect(cubit.weight, isNull);
      expect(cubit.activityLevelId, isNull);
      expect(cubit.goalId, isNull);
      expect(cubit.branchId, isNull);
      expect(cubit.dietType, isNull);
      expect(cubit.dailyMeals, isNull);
      expect(cubit.preferredFoods, isNull);
      expect(cubit.dislikedFoods, isNull);
      expect(cubit.foodAllergies, isNull);
      expect(cubit.weeklyWorkouts, isNull);
      expect(cubit.dailySteps, isNull);
      expect(cubit.preferredExercises, isNull);
      expect(cubit.dailyWorkoutHours, isNull);
    });
  });
}
