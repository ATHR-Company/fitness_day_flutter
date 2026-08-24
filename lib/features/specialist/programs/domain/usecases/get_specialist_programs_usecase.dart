import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/programs/data/models/specialist_program_model.dart';
import 'package:fitness_day/features/specialist/programs/domain/repositories/specialist_programs_repository.dart';

class GetSpecialistProgramsUseCase {
  final SpecialistProgramsRepository repository;

  GetSpecialistProgramsUseCase(this.repository);

  Future<ApiResult<SpecialistProgramsResponseModel>> call({
    required int page,
    required int limit,
    String? search,
  }) {
    return repository.getPrograms(page: page, limit: limit, search: search);
  }
}
