import 'specialist_assessment_health_report_model.dart';

class SpecialistUpdateHealthReportResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistUpdateHealthReportDataModel? data;

  SpecialistUpdateHealthReportResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistUpdateHealthReportResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateHealthReportResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistUpdateHealthReportDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistUpdateHealthReportDataModel {
  final String assessmentId;
  final SpecialistAssessmentHealthReportModel? healthReport;

  SpecialistUpdateHealthReportDataModel({
    required this.assessmentId,
    this.healthReport,
  });

  factory SpecialistUpdateHealthReportDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistUpdateHealthReportDataModel(
      assessmentId: json['assessmentId'] as String? ?? '',
      healthReport: json['healthReport'] != null
          ? SpecialistAssessmentHealthReportModel.fromJson(json['healthReport'] as Map<String, dynamic>)
          : null,
    );
  }
}
