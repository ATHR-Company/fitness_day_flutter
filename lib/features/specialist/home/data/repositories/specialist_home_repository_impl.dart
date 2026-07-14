import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/specialist/home/data/datasources/specialist_home_remote_datasource.dart';
import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';
import 'package:fitness_day/features/specialist/home/domain/repositories/specialist_home_repository.dart';

class SpecialistHomeRepositoryImpl implements SpecialistHomeRepository {
  final SpecialistHomeRemoteDataSource remoteDataSource;

  SpecialistHomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistHomeResponseModel>> getSpecialistHomeData() async {
    try {
      final response = await remoteDataSource.getSpecialistHomeData();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
