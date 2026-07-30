import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/points_reward_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class GetPointsRewardsUseCase {
  final RewardsRepository _repository;

  GetPointsRewardsUseCase(this._repository);

  Future<ApiResult<PointsRewardsModel>> call() => _repository.getPointsRewards();
}
