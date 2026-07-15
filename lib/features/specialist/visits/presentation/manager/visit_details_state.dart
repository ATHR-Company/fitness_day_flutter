import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_visit_data_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_health_report_model.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';

sealed class VisitDetailsState {
  const VisitDetailsState();
}

class VisitDetailsInitial extends VisitDetailsState {
  const VisitDetailsInitial();
}

class VisitDetailsLoading extends VisitDetailsState {
  const VisitDetailsLoading();
}

class VisitDetailsSuccess extends VisitDetailsState {
  final SpecialistAssessmentVisitDataModel? visitData;
  final SpecialistAssessmentHealthReportModel? healthReport;
  final SpecialistAssessmentCustomPlanModel? customPlan;
  final Map<int, SpecialistAssessmentCustomPlanModel> customPlanCache;

  const VisitDetailsSuccess({
    this.visitData,
    this.healthReport,
    this.customPlan,
    required this.customPlanCache,
  });

  VisitDetailsSuccess copyWith({
    SpecialistAssessmentVisitDataModel? visitData,
    SpecialistAssessmentHealthReportModel? healthReport,
    SpecialistAssessmentCustomPlanModel? customPlan,
    Map<int, SpecialistAssessmentCustomPlanModel>? customPlanCache,
  }) {
    return VisitDetailsSuccess(
      visitData: visitData ?? this.visitData,
      healthReport: healthReport ?? this.healthReport,
      customPlan: customPlan ?? this.customPlan,
      customPlanCache: customPlanCache ?? this.customPlanCache,
    );
  }
}

class VisitDetailsFailure extends VisitDetailsState {
  final String message;

  const VisitDetailsFailure(this.message);
}
