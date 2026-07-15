import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_goal_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class UpdateGoalUseCase {
  final SpecialistVisitsRepository repository;

  UpdateGoalUseCase(this.repository);

  Future<ApiResult<SpecialistUpdateGoalResponseModel>> call({
    required String assessmentId,
    required String goal,
  }) {
    return repository.updateGoal(assessmentId: assessmentId, goal: goal);
  }
}
