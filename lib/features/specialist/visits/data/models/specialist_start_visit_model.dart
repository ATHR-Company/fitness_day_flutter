class SpecialistStartVisitResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistStartVisitDataModel? data;

  SpecialistStartVisitResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistStartVisitResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistStartVisitResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistStartVisitDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistStartVisitDataModel {
  final String assessmentId;
  final bool isStarted;

  SpecialistStartVisitDataModel({
    required this.assessmentId,
    required this.isStarted,
  });

  factory SpecialistStartVisitDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistStartVisitDataModel(
      assessmentId: json['assessmentId'] as String? ?? '',
      isStarted: json['isStarted'] as bool? ?? false,
    );
  }
}
