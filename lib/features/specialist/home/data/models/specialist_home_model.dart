class SpecialistHomeResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistHomeDataModel? data;

  SpecialistHomeResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistHomeResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistHomeResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistHomeDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistHomeDataModel {
  final String name;
  final String avatar;
  final String branch;
  final PerformanceSummaryModel? performanceSummary;
  final List<UpcomingAssessmentModel> upcomingAssessments;
  final NeedsFollowUpModel? needsFollowUp;

  SpecialistHomeDataModel({
    required this.name,
    required this.avatar,
    required this.branch,
    this.performanceSummary,
    required this.upcomingAssessments,
    this.needsFollowUp,
  });

  factory SpecialistHomeDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistHomeDataModel(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      branch: json['branch'] as String? ?? '',
      performanceSummary: json['performanceSummary'] != null
          ? PerformanceSummaryModel.fromJson(json['performanceSummary'] as Map<String, dynamic>)
          : null,
      upcomingAssessments: (json['upcomingAssessments'] as List<dynamic>?)
              ?.map((e) => UpcomingAssessmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      needsFollowUp: json['needsFollowUp'] != null
          ? NeedsFollowUpModel.fromJson(json['needsFollowUp'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PerformanceSummaryModel {
  final int clientsCount;
  final int needsFollowUpCount;
  final int dailyVisitsCount;

  PerformanceSummaryModel({
    required this.clientsCount,
    required this.needsFollowUpCount,
    required this.dailyVisitsCount,
  });

  factory PerformanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return PerformanceSummaryModel(
      clientsCount: json['clientsCount'] as int? ?? 0,
      needsFollowUpCount: json['needsFollowUpCount'] as int? ?? 0,
      dailyVisitsCount: json['dailyVisitsCount'] as int? ?? 0,
    );
  }
}

class UpcomingAssessmentModel {
  final AssessmentUserModel? user;
  final String assessmentId;
  final String name;
  final String description;
  final String image;
  final String placement;
  final String weekStart;
  final String previousAppointment;
  final bool isNew;

  UpcomingAssessmentModel({
    this.user,
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.image,
    required this.placement,
    required this.weekStart,
    required this.previousAppointment,
    required this.isNew,
  });

  factory UpcomingAssessmentModel.fromJson(Map<String, dynamic> json) {
    return UpcomingAssessmentModel(
      user: json['user'] != null
          ? AssessmentUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      assessmentId: json['assessmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      weekStart: json['weekStart'] as String? ?? '',
      previousAppointment: json['previousAppointment'] as String? ?? '',
      isNew: json['isNew'] as bool? ?? false,
    );
  }
}

class AssessmentUserModel {
  final String id;
  final String name;
  final int adherenceRate;

  AssessmentUserModel({
    required this.id,
    required this.name,
    required this.adherenceRate,
  });

  factory AssessmentUserModel.fromJson(Map<String, dynamic> json) {
    return AssessmentUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      adherenceRate: json['adherenceRate'] as int? ?? 0,
    );
  }
}

class NeedsFollowUpModel {
  final String id;
  final String name;
  final String image;
  final String reason;

  NeedsFollowUpModel({
    required this.id,
    required this.name,
    required this.image,
    required this.reason,
  });

  factory NeedsFollowUpModel.fromJson(Map<String, dynamic> json) {
    return NeedsFollowUpModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}
