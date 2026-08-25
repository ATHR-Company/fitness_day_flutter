import 'assessment_current_state.dart';

class SpecialistAssessmentVisitDataResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistAssessmentVisitDataModel? data;

  SpecialistAssessmentVisitDataResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistAssessmentVisitDataResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentVisitDataResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistAssessmentVisitDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistAssessmentVisitDataModel {
  final SpecialistAssessmentUserModel? user;

  /// Existing conversation with this client, or `null` when there is none yet —
  /// the chat screen creates one from `user.id` in that case.
  final String? conversationId;

  final String assessmentId;
  final String name;
  final String description;
  final String image;
  final String placement;
  final String weekStart;
  final double adherenceRate;
  final String? goal;

  /// Written by the specialist about the client, read by the admin dashboard.
  /// Comes back on this (specialist) route only — the client's own visit
  /// responses never carry it.
  final String? clientNotes;

  final bool isStarted;
  final bool canFinishAssessment;
  // Null when the backend doesn't send this field yet — see [AssessmentCurrentState.fromJson].
  final AssessmentCurrentState? currentState;

  SpecialistAssessmentVisitDataModel({
    this.user,
    this.conversationId,
    required this.assessmentId,
    required this.name,
    required this.description,
    required this.image,
    required this.placement,
    required this.weekStart,
    required this.adherenceRate,
    this.goal,
    this.clientNotes,
    required this.isStarted,
    required this.canFinishAssessment,
    this.currentState,
  });

  factory SpecialistAssessmentVisitDataModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentVisitDataModel(
      user: json['user'] != null
          ? SpecialistAssessmentUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      conversationId: json['conversationId'] as String?,
      assessmentId: json['assessmentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      placement: json['placement'] as String? ?? '',
      weekStart: json['weekStart'] as String? ?? '',
      adherenceRate: (json['adherenceRate'] as num?)?.toDouble() ?? 0.0,
      goal: json['goal'] as String?,
      clientNotes: json['clientNotes'] as String?,
      isStarted: json['isStarted'] as bool? ?? false,
      canFinishAssessment: json['canFinishAssessment'] as bool? ?? false,
      currentState: AssessmentCurrentState.fromJson(json['currentState'] as String?),
    );
  }

  SpecialistAssessmentVisitDataModel copyWith({
    SpecialistAssessmentUserModel? user,
    String? conversationId,
    String? assessmentId,
    String? name,
    String? description,
    String? image,
    String? placement,
    String? weekStart,
    double? adherenceRate,
    String? goal,
    String? clientNotes,
    bool? isStarted,
    bool? canFinishAssessment,
    AssessmentCurrentState? currentState,
  }) {
    return SpecialistAssessmentVisitDataModel(
      user: user ?? this.user,
      conversationId: conversationId ?? this.conversationId,
      assessmentId: assessmentId ?? this.assessmentId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      placement: placement ?? this.placement,
      weekStart: weekStart ?? this.weekStart,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      goal: goal ?? this.goal,
      clientNotes: clientNotes ?? this.clientNotes,
      isStarted: isStarted ?? this.isStarted,
      canFinishAssessment: canFinishAssessment ?? this.canFinishAssessment,
      currentState: currentState ?? this.currentState,
    );
  }
}

class SpecialistAssessmentUserModel {
  final String id;
  final String name;

  SpecialistAssessmentUserModel({
    required this.id,
    required this.name,
  });

  factory SpecialistAssessmentUserModel.fromJson(Map<String, dynamic> json) {
    return SpecialistAssessmentUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
