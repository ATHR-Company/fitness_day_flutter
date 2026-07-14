import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/features/specialist/profile/data/datasources/specialist_profile_remote_datasource.dart';
import 'package:fitness_day/features/specialist/profile/data/models/specialist_profile_model.dart';
import 'package:fitness_day/features/specialist/profile/domain/repositories/specialist_profile_repository.dart';

class SpecialistProfileRepositoryImpl implements SpecialistProfileRepository {
  final SpecialistProfileRemoteDataSource remoteDataSource;

  SpecialistProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistProfileResponseModel>> getSpecialistProfile() async {
    try {
      final response = await remoteDataSource.getSpecialistProfile();
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
