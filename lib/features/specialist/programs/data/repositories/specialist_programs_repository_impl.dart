import 'package:fitness_day/core/errors/error_handler.dart';
import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/programs/data/datasources/specialist_programs_remote_datasource.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';
import 'package:fitness_day/features/specialist/programs/domain/repositories/specialist_programs_repository.dart';

class SpecialistProgramsRepositoryImpl
    implements SpecialistProgramsRepository {
  final SpecialistProgramsRemoteDataSource remoteDataSource;

  SpecialistProgramsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<SpecialistProgramsResponseModel>> getPrograms({
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final response = await remoteDataSource.getPrograms(
        page: page,
        limit: limit,
        search: search,
      );
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<SpecialistProgramWeeksResponseModel>> getProgramWeeks({
    required String programId,
  }) async {
    try {
      final response =
          await remoteDataSource.getProgramWeeks(programId: programId);
      return Success(response);
    } catch (e) {
      return FailureResult(ErrorHandler.handle(e));
    }
  }
}
