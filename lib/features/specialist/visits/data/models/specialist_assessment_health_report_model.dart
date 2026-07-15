class SpecialistAssessmentHealthReportResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistAssessmentHealthReportModel? data;

  SpecialistAssessmentHealthReportResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistAssessmentHealthReportResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentHealthReportResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistAssessmentHealthReportModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistAssessmentHealthReportModel {
  final ReportMetricModel? weight;
  final ReportMetricModel? height;
  final ReportMetricModel? bmi;
  final ReportMetricModel? bmr;
  final ReportMetricModel? fatWeight;
  final ReportMetricModel? fatPercentage;
  final ReportMetricModel? muscleWeight;
  final ReportMetricModel? musclePercentage;
  final ReportMetricModel? protein;

  SpecialistAssessmentHealthReportModel({
    this.weight,
    this.height,
    this.bmi,
    this.bmr,
    this.fatWeight,
    this.fatPercentage,
    this.muscleWeight,
    this.musclePercentage,
    this.protein,
  });

  factory SpecialistAssessmentHealthReportModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentHealthReportModel(
      weight: json['weight'] != null ? ReportMetricModel.fromJson(json['weight'] as Map<String, dynamic>) : null,
      height: json['height'] != null ? ReportMetricModel.fromJson(json['height'] as Map<String, dynamic>) : null,
      bmi: json['bmi'] != null ? ReportMetricModel.fromJson(json['bmi'] as Map<String, dynamic>) : null,
      bmr: json['bmr'] != null ? ReportMetricModel.fromJson(json['bmr'] as Map<String, dynamic>) : null,
      fatWeight: json['fatWeight'] != null ? ReportMetricModel.fromJson(json['fatWeight'] as Map<String, dynamic>) : null,
      fatPercentage: json['fatPercentage'] != null
          ? ReportMetricModel.fromJson(json['fatPercentage'] as Map<String, dynamic>)
          : null,
      muscleWeight:
          json['muscleWeight'] != null ? ReportMetricModel.fromJson(json['muscleWeight'] as Map<String, dynamic>) : null,
      musclePercentage: json['musclePercentage'] != null
          ? ReportMetricModel.fromJson(json['musclePercentage'] as Map<String, dynamic>)
          : null,
      protein: json['protein'] != null ? ReportMetricModel.fromJson(json['protein'] as Map<String, dynamic>) : null,
    );
  }
}

class ReportMetricModel {
  final double value;
  final String unit;
  final String? status;

  ReportMetricModel({
    required this.value,
    required this.unit,
    this.status,
  });

  factory ReportMetricModel.fromJson(Map<String, dynamic> json) {
    return ReportMetricModel(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      status: json['status'] as String?,
    );
  }
}
