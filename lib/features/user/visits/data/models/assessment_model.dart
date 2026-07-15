class AssessmentModel {
  final String assessmentId;
  final String name;
  final String description;
  final String specialistName;
  final DateTime appointment;
  final String placement;
  final String image;
  final bool canShowDetails;
  final bool canChangePlaceOrTime;

  AssessmentModel({
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.specialistName,
    required this.appointment,
    required this.placement,
    required this.image,
    required this.canShowDetails,
    required this.canChangePlaceOrTime,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      assessmentId: json['assessmentId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      specialistName: json['specialistName'] ?? '',
      appointment: json['appointment'] != null
          ? DateTime.parse(json['appointment']).toLocal()
          : DateTime.now(),
      placement: json['placement'] ?? '',
      image: json['image'] ?? '',
      canShowDetails: json['canShowDetails'] ?? false,
      canChangePlaceOrTime: json['canChangePlaceOrTime'] ?? false,
    );
  }
}

class AssessmentsResponse {
  final List<AssessmentModel> assessments;
  final DateTime firstDateOfWeekStart;
  final DateTime lastDateOfWeekStart;

  AssessmentsResponse({
    required this.assessments,
    required this.firstDateOfWeekStart,
    required this.lastDateOfWeekStart,
  });

  factory AssessmentsResponse.fromJson(Map<String, dynamic> json) {
    return AssessmentsResponse(
      assessments: (json['assessments'] as List?)
              ?.map((e) => AssessmentModel.fromJson(e))
              .toList() ??
          [],
      firstDateOfWeekStart: json['firstDateOfWeekStart'] != null
          ? DateTime.parse(json['firstDateOfWeekStart']).toLocal()
          : DateTime.now(),
      lastDateOfWeekStart: json['lastDateOfWeekStart'] != null
          ? DateTime.parse(json['lastDateOfWeekStart']).toLocal()
          : DateTime.now(),
    );
  }
}
