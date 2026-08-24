import 'package:fitness_day/features/specialist/visits/data/models/assessment_current_state.dart';
import 'package:fitness_day/features/specialist/visits/data/models/specialist_assessment_custom_plan_model.dart';

/// The response to `POST specialist/assessments/:id/apply-program`.
///
/// It carries **all seven days**, not just the one the specialist happened to
/// be looking at, because applying a week rewrites the whole visit. That is
/// what lets the cubit repopulate its per-day plan cache in one go instead of
/// invalidating it and paying for seven refetches as the specialist flips
/// through the day tabs.
class SpecialistApplyProgramResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistApplyProgramModel? data;

  SpecialistApplyProgramResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistApplyProgramResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SpecialistApplyProgramResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistApplyProgramModel.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistApplyProgramModel {
  final List<SpecialistAssessmentCustomPlanModel> days;
  final AppliedProgramModel? appliedProgram;
  final AssessmentCurrentState? currentState;

  SpecialistApplyProgramModel({
    required this.days,
    this.appliedProgram,
    this.currentState,
  });

  factory SpecialistApplyProgramModel.fromJson(Map<String, dynamic> json) {
    final stateStr = json['currentState'] as String?;

    /*
      `currentState` is on the envelope, once, while the day model reads it off
      its own map. Folding it into each day keeps the cached days
      indistinguishable from the ones `getCustomPlan` returns — which is what
      lets `_handleApplyProgramResult` reuse the same cache the manual add/edit
      path fills.
    */
    final days = (json['days'] as List<dynamic>?)
            ?.map((e) => SpecialistAssessmentCustomPlanModel.fromJson({
                  ...(e as Map<String, dynamic>),
                  'currentState': stateStr,
                }))
            .toList() ??
        const <SpecialistAssessmentCustomPlanModel>[];

    return SpecialistApplyProgramModel(
      days: days,
      appliedProgram: json['appliedProgram'] != null
          ? AppliedProgramModel.fromJson(
              json['appliedProgram'] as Map<String, dynamic>)
          : null,
      currentState: AssessmentCurrentState.fromJson(stateStr),
    );
  }
}

/// What was applied, echoed back for the success message. A record of the
/// event — the visit holds copies of the plan, not a link to the program.
class AppliedProgramModel {
  final String programId;
  final String name;
  final int weekNumber;

  AppliedProgramModel({
    required this.programId,
    required this.name,
    required this.weekNumber,
  });

  factory AppliedProgramModel.fromJson(Map<String, dynamic> json) {
    return AppliedProgramModel(
      programId: json['programId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      weekNumber: json['weekNumber'] as int? ?? 0,
    );
  }
}
