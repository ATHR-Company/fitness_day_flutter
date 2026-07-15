class SpecialistUpdateGoalResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistUpdateGoalDataModel? data;

  SpecialistUpdateGoalResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistUpdateGoalResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateGoalResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistUpdateGoalDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistUpdateGoalDataModel {
  final String assessmentId;
  final String goal;

  SpecialistUpdateGoalDataModel({
    required this.assessmentId,
    required this.goal,
  });

  factory SpecialistUpdateGoalDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateGoalDataModel(
      assessmentId: json['assessmentId'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
    );
  }
}
