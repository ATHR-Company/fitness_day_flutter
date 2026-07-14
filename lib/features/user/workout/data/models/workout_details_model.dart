class PhaseVideoModel {
  final String videoUrl;

  const PhaseVideoModel({required this.videoUrl});

  factory PhaseVideoModel.fromJson(Map<String, dynamic> json) {
    return PhaseVideoModel(
      videoUrl: json['videoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoUrl': videoUrl,
    };
  }
}

class WorkoutPhasesModel {
  final PhaseVideoModel? warmup;
  final PhaseVideoModel? exercise;
  final PhaseVideoModel? coolDown;

  const WorkoutPhasesModel({
    this.warmup,
    this.exercise,
    this.coolDown,
  });

  factory WorkoutPhasesModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPhasesModel(
      warmup: json['warmup'] != null
          ? PhaseVideoModel.fromJson(json['warmup'] as Map<String, dynamic>)
          : null,
      exercise: json['exercise'] != null
          ? PhaseVideoModel.fromJson(json['exercise'] as Map<String, dynamic>)
          : null,
      coolDown: json['coolDown'] != null
          ? PhaseVideoModel.fromJson(json['coolDown'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warmup': warmup?.toJson(),
      'exercise': exercise?.toJson(),
      'coolDown': coolDown?.toJson(),
    };
  }
}

class WorkoutDetailsModel {
  final String id;
  final String assessmentId;
  final int dayNumber;
  final String exerciseId;
  final String name;
  final String description;
  final List<String> steps;
  final List<String> warnings;
  final String photo;
  final WorkoutPhasesModel phases;
  final int sets;
  final int reps;
  final int restDuration;
  final String time;
  final int totalSets;
  final int completedSets;

  const WorkoutDetailsModel({
    required this.id,
    required this.assessmentId,
    required this.dayNumber,
    required this.exerciseId,
    required this.name,
    required this.description,
    required this.steps,
    required this.warnings,
    required this.photo,
    required this.phases,
    required this.sets,
    required this.reps,
    required this.restDuration,
    required this.time,
    required this.totalSets,
    required this.completedSets,
  });

  factory WorkoutDetailsModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDetailsModel(
      id: json['workoutItemId'] as String? ?? json['id'] as String? ?? json['_id'] as String? ?? '',
      assessmentId: json['assessmentId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      exerciseId: json['exerciseId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      warnings: (json['warnings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      photo: json['photo'] as String? ?? '',
      phases: json['phases'] != null
          ? WorkoutPhasesModel.fromJson(json['phases'] as Map<String, dynamic>)
          : const WorkoutPhasesModel(),
      sets: json['sets'] as int? ?? 0,
      reps: json['reps'] as int? ?? 0,
      restDuration: json['restDuration'] as int? ?? 0,
      time: json['time'] as String? ?? '',
      totalSets: json['totalSets'] as int? ?? 0,
      completedSets: json['completedSets'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assessmentId': assessmentId,
      'dayNumber': dayNumber,
      'exerciseId': exerciseId,
      'name': name,
      'description': description,
      'steps': steps,
      'warnings': warnings,
      'photo': photo,
      'phases': phases.toJson(),
      'sets': sets,
      'reps': reps,
      'restDuration': restDuration,
      'time': time,
      'totalSets': totalSets,
      'completedSets': completedSets,
    };
  }
}

class WorkoutDetailsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final WorkoutDetailsModel? data;

  const WorkoutDetailsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory WorkoutDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDetailsResponseModel(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? WorkoutDetailsModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
