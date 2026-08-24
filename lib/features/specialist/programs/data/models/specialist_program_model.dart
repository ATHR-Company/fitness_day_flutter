/// Programs — dashboard-authored plan templates.
///
/// The specialist app never edits one. It lists them, shows the weeks, and
/// applies a week onto a visit; the plan itself is only ever seen afterwards,
/// on the visit screen, as ordinary meals/exercises/activities.
///
/// The backend only lists programs that are active **and** complete, so the
/// picker never has to reason about drafts.
class SpecialistProgramsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<SpecialistProgramModel> data;
  final int totalCount;
  final int totalPages;

  SpecialistProgramsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.totalCount,
    required this.totalPages,
  });

  factory SpecialistProgramsResponseModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProgramsResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) =>
                  SpecialistProgramModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }
}

class SpecialistProgramModel {
  final String id;
  final String name;
  final String description;

  /// Already an absolute URL — the backend resolves it, unlike meal and
  /// exercise media which arrive as bare filenames.
  final String image;
  final int weeksCount;

  SpecialistProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.weeksCount,
  });

  factory SpecialistProgramModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProgramModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      weeksCount: json['weeksCount'] as int? ?? 0,
    );
  }
}

class SpecialistProgramWeeksResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final SpecialistProgramWeeksModel? data;

  SpecialistProgramWeeksResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SpecialistProgramWeeksResponseModel.fromJson(
      Map<String, dynamic> json) {
    return SpecialistProgramWeeksResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SpecialistProgramWeeksModel.fromJson(
              json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpecialistProgramWeeksModel {
  final SpecialistProgramModel? program;
  final List<SpecialistProgramWeekModel> weeks;

  SpecialistProgramWeeksModel({this.program, required this.weeks});

  factory SpecialistProgramWeeksModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProgramWeeksModel(
      program: json['program'] != null
          ? SpecialistProgramModel.fromJson(
              json['program'] as Map<String, dynamic>)
          : null,
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((e) => SpecialistProgramWeekModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// One week, with the counts the confirmation sheet shows so the specialist
/// knows what they are about to overwrite the visit with. The plan itself is
/// never sent.
class SpecialistProgramWeekModel {
  final int weekNumber;
  final int daysCount;
  final int mealsCount;
  final int workoutsCount;
  final int activitiesCount;
  final bool isComplete;

  SpecialistProgramWeekModel({
    required this.weekNumber,
    required this.daysCount,
    required this.mealsCount,
    required this.workoutsCount,
    required this.activitiesCount,
    required this.isComplete,
  });

  factory SpecialistProgramWeekModel.fromJson(Map<String, dynamic> json) {
    return SpecialistProgramWeekModel(
      weekNumber: json['weekNumber'] as int? ?? 0,
      daysCount: json['daysCount'] as int? ?? 0,
      mealsCount: json['mealsCount'] as int? ?? 0,
      workoutsCount: json['workoutsCount'] as int? ?? 0,
      activitiesCount: json['activitiesCount'] as int? ?? 0,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}
