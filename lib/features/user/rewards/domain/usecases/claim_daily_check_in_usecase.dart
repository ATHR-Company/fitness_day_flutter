import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/daily_check_in_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class ClaimDailyCheckInUseCase {
  final RewardsRepository _repository;

  ClaimDailyCheckInUseCase(this._repository);

  Future<ApiResult<DailyCheckInStatusModel>> call() =>
      _repository.claimDailyCheckIn();
}
