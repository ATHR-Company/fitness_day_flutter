import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/auth/data/models/health_questions_model.dart';
import 'package:fitness_day/features/user/auth/domain/repositories/user_auth_repository.dart';

class GetHealthQuestionsUseCase {
  final UserAuthRepository _repository;

  GetHealthQuestionsUseCase(this._repository);

  Future<ApiResult<HealthQuestionsResponseModel>> call() {
    return _repository.getHealthQuestions();
  }
}
