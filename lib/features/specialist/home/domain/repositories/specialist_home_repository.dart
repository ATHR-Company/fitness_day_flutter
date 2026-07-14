import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/home/data/models/specialist_home_model.dart';

abstract class SpecialistHomeRepository {
  Future<ApiResult<SpecialistHomeResponseModel>> getSpecialistHomeData();
}
