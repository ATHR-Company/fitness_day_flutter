import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';

abstract class UserProgressRepository {
  Future<ApiResult<ClientProgressResponseModel>> getUserProgress({
    required int visitNumber,
  });
}
