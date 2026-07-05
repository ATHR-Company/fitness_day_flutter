import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';

import 'package:fitness_day/features/user/auth/data/models/social_auth_models.dart';

abstract class UserAuthRepository {
  Future<ApiResult<UserSignupResponseModel>> signup(UserSignupRequest request);
  Future<ApiResult<UserVerifyOtpResponseModel>> verifyOtp(UserVerifyOtpRequest request);
  Future<ApiResult<UserVerifyOtpResponseModel>> socialAuth(SocialAuthRequest request);
  Future<ApiResult<UserLookupsResponseModel>> getLookups();
  Future<ApiResult<HealthQuestionsResponseModel>> getHealthQuestions();
  Future<ApiResult<CompletePersonalDataResponseModel>> completePersonalData(
    CompletePersonalDataRequest request,
  );
  Future<ApiResult<SubmitHealthAnswersResponseModel>> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  );
}
