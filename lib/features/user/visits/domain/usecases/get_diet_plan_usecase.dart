import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/diet_plan_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

class GetDietPlanUseCase {
  final VisitsRepository _repository;

  GetDietPlanUseCase(this._repository);

  Future<ApiResult<DietPlanResponseModel>> call(int day) {
    return _repository.getDietPlan(day);
  }
}
