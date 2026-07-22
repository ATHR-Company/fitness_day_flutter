import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';
import 'package:fitness_day/features/user/progress/domain/repositories/user_progress_repository.dart';

class GetUserProgressUseCase {
  final UserProgressRepository repository;

  GetUserProgressUseCase(this.repository);

  Future<ApiResult<ClientProgressResponseModel>> call({
    required int visitNumber,
  }) {
    return repository.getUserProgress(visitNumber: visitNumber);
  }
}
