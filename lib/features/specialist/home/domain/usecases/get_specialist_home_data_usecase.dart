import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';
import 'package:fitness_day/features/specialist/home/domain/repositories/specialist_home_repository.dart';

class GetSpecialistHomeDataUseCase {
  final SpecialistHomeRepository repository;

  GetSpecialistHomeDataUseCase(this.repository);

  Future<ApiResult<SpecialistHomeResponseModel>> call() {
    return repository.getSpecialistHomeData();
  }
}
