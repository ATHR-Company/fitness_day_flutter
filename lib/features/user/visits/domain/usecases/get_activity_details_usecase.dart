import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/user/visits/data/models/activity_details_model.dart';
import 'package:fitness_day/features/user/visits/domain/repositories/visits_repository.dart';

class GetActivityDetailsUseCase {
  final VisitsRepository _repository;

  GetActivityDetailsUseCase(this._repository);

  Future<ApiResult<ActivityDetailsResponseModel>> call(
      String assessmentId, int dayNumber, String activityId,
      {String period = 'daily'}) {
    return _repository.getActivityDetails(assessmentId, dayNumber, activityId,
        period: period);
  }
}
