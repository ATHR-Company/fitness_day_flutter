import 'package:fitness_day/core/network/api_result.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_update_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/domain/repositories/specialist_visits_repository.dart';

class UpdateHealthReportUseCase {
  final SpecialistVisitsRepository _repository;

  UpdateHealthReportUseCase(this._repository);

  Future<ApiResult<SpecialistUpdateHealthReportResponseModel>> call({
    required String assessmentId,
    required double weight,
    required double height,
    required double bmi,
    required double bmr,
    required double fatWeight,
    required double fatPercentage,
    required double muscleWeight,
    required double musclePercentage,
    required double protein,
  }) {
    return _repository.updateHealthReport(
      assessmentId: assessmentId,
      weight: weight,
      height: height,
      bmi: bmi,
      bmr: bmr,
      fatWeight: fatWeight,
      fatPercentage: fatPercentage,
      muscleWeight: muscleWeight,
      musclePercentage: musclePercentage,
      protein: protein,
    );
  }
}
