import 'package:fitness_day/core/network/api_result.dart';
import '../entities/plans_data.dart';
import '../repositories/market_repository.dart';

class GetPlanByIdUseCase {
  final MarketRepository repository;

  GetPlanByIdUseCase(this.repository);

  Future<ApiResult<PlanDetails>> call(String id) => repository.getPlanById(id);
}
