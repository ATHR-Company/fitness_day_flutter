import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/rewards/data/models/check_in_calendar_models.dart';
import 'package:fitness_day/features/user/rewards/domain/repositories/rewards_repository.dart';

class GetCheckInCalendarUseCase {
  final RewardsRepository _repository;

  GetCheckInCalendarUseCase(this._repository);

  /// Both params are optional; omitting them returns the current UTC month.
  Future<ApiResult<CheckInCalendarModel>> call({int? year, int? month}) =>
      _repository.getCheckInCalendar(year: year, month: month);
}
