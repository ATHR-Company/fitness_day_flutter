import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class RedeemRewardUseCase {
  final RewardsRepository _repository;

  RedeemRewardUseCase(this._repository);

  Future<ApiResult<RedeemRewardResultModel>> call(String rewardId) =>
      _repository.redeemReward(rewardId);
}
