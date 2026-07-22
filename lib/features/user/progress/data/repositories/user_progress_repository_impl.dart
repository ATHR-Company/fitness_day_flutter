import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/clients/data/models/client_progress_model.dart';
import 'package:fitness_day/features/user/progress/data/datasources/user_progress_remote_datasource.dart';
import 'package:fitness_day/features/user/progress/domain/repositories/user_progress_repository.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  final UserProgressRemoteDataSource remoteDataSource;

  UserProgressRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<ClientProgressResponseModel>> getUserProgress({
    required int visitNumber,
  }) async {
    try {
      final response = await remoteDataSource.getUserProgress(visitNumber: visitNumber);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
