import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/redemption_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class GetRedemptionsUseCase {
  final RewardsRepository _repository;

  GetRedemptionsUseCase(this._repository);

  Future<ApiResult<RedemptionsPageModel>> call({int page = 1, int limit = 10}) =>
      _repository.getRedemptions(page: page, limit: limit);
}
