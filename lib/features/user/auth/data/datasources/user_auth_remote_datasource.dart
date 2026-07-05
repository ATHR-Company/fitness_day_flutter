import 'package:fitness_day/core/network/api_service.dart';
import 'package:fitness_day/core/constant/api_endpoints.dart';
import 'package:fitness_day/features/user/auth/data/models/user_signup_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_verify_otp_models.dart';
import 'package:fitness_day/features/user/auth/data/models/user_lookups_model.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/data/models/complete_personal_data_models.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';

abstract class UserAuthRemoteDataSource {
  Future<UserSignupResponseModel> signup(UserSignupRequest request);
  Future<UserVerifyOtpResponseModel> verifyOtp(UserVerifyOtpRequest request);
  Future<UserLookupsResponseModel> getLookups();
  Future<HealthQuestionsResponseModel> getHealthQuestions();
  Future<CompletePersonalDataResponseModel> completePersonalData(
    CompletePersonalDataRequest request,
  );
  Future<SubmitHealthAnswersResponseModel> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  );
}

class UserAuthRemoteDataSourceImpl implements UserAuthRemoteDataSource {
  final ApiService _apiService;

  UserAuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<UserSignupResponseModel> signup(UserSignupRequest request) async {
    final response = await _apiService.post(
      ApiEndpoints.userSignup,
      data: request.toJson(),
    );
    return UserSignupResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserVerifyOtpResponseModel> verifyOtp(UserVerifyOtpRequest request) async {
    final response = await _apiService.post(
      ApiEndpoints.userVerifyOtp,
      data: request.toJson(),
    );
    return UserVerifyOtpResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserLookupsResponseModel> getLookups() async {
    final response = await _apiService.get(ApiEndpoints.userLookups);
    return UserLookupsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<HealthQuestionsResponseModel> getHealthQuestions() async {
    final response = await _apiService.get(ApiEndpoints.healthQuestions);
    return HealthQuestionsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CompletePersonalDataResponseModel> completePersonalData(
    CompletePersonalDataRequest request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.completePersonalData,
      data: request.toJson(),
    );
    return CompletePersonalDataResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<SubmitHealthAnswersResponseModel> submitHealthAnswers(
    SubmitHealthAnswersRequest request,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.submitHealthAnswers,
      data: request.toJson(),
    );
    return SubmitHealthAnswersResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
