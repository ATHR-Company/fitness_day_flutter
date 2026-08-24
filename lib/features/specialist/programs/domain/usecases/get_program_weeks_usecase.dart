import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';
import 'package:fitness_day/features/specialist/programs/domain/repositories/specialist_programs_repository.dart';

class GetProgramWeeksUseCase {
  final SpecialistProgramsRepository repository;

  GetProgramWeeksUseCase(this.repository);

  Future<ApiResult<SpecialistProgramWeeksResponseModel>> call({
    required String programId,
  }) {
    return repository.getProgramWeeks(programId: programId);
  }
}
