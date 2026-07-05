import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/submit_health_answers_models.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class SubmitHealthAnswersUseCase {
  final UserAuthRepository _repository;

  SubmitHealthAnswersUseCase(this._repository);

  Future<ApiResult<SubmitHealthAnswersResponseModel>> call(SubmitHealthAnswersRequest request) {
    return _repository.submitHealthAnswers(request);
  }
}
