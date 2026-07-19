import 'package:fitness_day/core/network/api_result.dart';
import '../entities/plans_data.dart';
import '../repositories/market_repository.dart';

class GetPlansUseCase {
  final MarketRepository repository;

  GetPlansUseCase(this.repository);

  Future<ApiResult<PlansData>> call({int page = 1, int limit = 8}) =>
      repository.getPlans(page: page, limit: limit);
}
