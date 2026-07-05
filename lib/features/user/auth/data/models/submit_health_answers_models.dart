class HealthAnswerItem {
  final String questionId;
  final bool answer;
  final String? details;

  const HealthAnswerItem({
    required this.questionId,
    required this.answer,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'question': questionId,
      'answer': answer,
    };
    if (details != null && details!.isNotEmpty) {
      map['details'] = details;
    }
    return map;
  }
}

class SubmitHealthAnswersRequest {
  final List<HealthAnswerItem> healthAnswers;

  const SubmitHealthAnswersRequest({
    required this.healthAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'healthAnswers': healthAnswers.map((e) => e.toJson()).toList(),
    };
  }
}

class ReportMetric {
  final double value;
  final String? status;
  final String unit;

  const ReportMetric({
    required this.value,
    this.status,
    required this.unit,
  });

  factory ReportMetric.fromJson(Map<String, dynamic> json) {
    return ReportMetric(
      value: (json['value'] as num).toDouble(),
      status: json['status'] as String?,
      unit: json['unit'] as String? ?? '',
    );
  }
}

class CurrentReportData {
  final double weight;
  final String weightUnit;
  final double height;
  final String heightUnit;
  final String activityLevel;
  final String goal;
  final String branch;

  const CurrentReportData({
    required this.weight,
    required this.weightUnit,
    required this.height,
    required this.heightUnit,
    required this.activityLevel,
    required this.goal,
    required this.branch,
  });

  factory CurrentReportData.fromJson(Map<String, dynamic> json) {
    final weightData = json['weight'] as Map<String, dynamic>;
    final heightData = json['height'] as Map<String, dynamic>;
    return CurrentReportData(
      weight: (weightData['value'] as num).toDouble(),
      weightUnit: weightData['unit'] as String? ?? '',
      height: (heightData['value'] as num).toDouble(),
      heightUnit: heightData['unit'] as String? ?? '',
      activityLevel: json['activityLevel'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
    );
  }
}

class BodyReportModel {
  final ReportMetric bmi;
  final ReportMetric idealWeight;
  final ReportMetric calories;
  final ReportMetric proteinNeeds;
  final CurrentReportData currentData;

  const BodyReportModel({
    required this.bmi,
    required this.idealWeight,
    required this.calories,
    required this.proteinNeeds,
    required this.currentData,
  });

  factory BodyReportModel.fromJson(Map<String, dynamic> json) {
    return BodyReportModel(
      bmi: ReportMetric.fromJson(json['bmi'] as Map<String, dynamic>),
      idealWeight: ReportMetric.fromJson(json['idealWeight'] as Map<String, dynamic>),
      calories: ReportMetric.fromJson(json['calories'] as Map<String, dynamic>),
      proteinNeeds: ReportMetric.fromJson(json['proteinNeeds'] as Map<String, dynamic>),
      currentData: CurrentReportData.fromJson(json['currentData'] as Map<String, dynamic>),
    );
  }
}

class SubmitHealthAnswersResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final bool isPersonalDataComplete;
  final bool isSurveyComplete;
  final BodyReportModel bodyReport;
  final bool isSubscribed;

  const SubmitHealthAnswersResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.isPersonalDataComplete,
    required this.isSurveyComplete,
    required this.bodyReport,
    required this.isSubscribed,
  });

  factory SubmitHealthAnswersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final completionStatus = data['completionStatus'] as Map<String, dynamic>;
    final bodyReportData = data['bodyReport'] as Map<String, dynamic>;
    return SubmitHealthAnswersResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      isPersonalDataComplete: completionStatus['isPersonalDataComplete'] as bool? ?? false,
      isSurveyComplete: completionStatus['isSurveyComplete'] as bool? ?? false,
      bodyReport: BodyReportModel.fromJson(bodyReportData),
      isSubscribed: data['isSubscriped'] as bool? ?? false,
    );
  }
}
