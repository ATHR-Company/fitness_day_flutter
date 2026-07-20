class SpecialistFinishVisitResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistFinishVisitDataModel? data;

  SpecialistFinishVisitResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistFinishVisitResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistFinishVisitResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistFinishVisitDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistFinishVisitDataModel {
  final String assessmentId;
  final bool isFinished;

  SpecialistFinishVisitDataModel({
    required this.assessmentId,
    required this.isFinished,
  });

  factory SpecialistFinishVisitDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistFinishVisitDataModel(
      assessmentId: json['assessmentId'] as String? ?? '',
      isFinished: json['isFinished'] as bool? ?? false,
    );
  }
}
