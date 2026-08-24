import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';

abstract class SpecialistProgramsRepository {
  Future<ApiResult<SpecialistProgramsResponseModel>> getPrograms({
    required int page,
    required int limit,
    String? search,
  });

  Future<ApiResult<SpecialistProgramWeeksResponseModel>> getProgramWeeks({
    required String programId,
  });
}
