class CompletePersonalDataRequest {
  final String fullName;
  final String gender;
  final String birthDate;
  final double height;
  final double weight;
  final String activityLevel;
  final String goal;
  final String branch;
  final String dietType;
  final int dailyMeals;
  final String preferredFoods;
  final String dislikedFoods;
  final String foodAllergies;
  final int weeklyWorkouts;
  final int dailySteps;
  final String preferredExercises;
  final double dailyWorkoutHours;

  const CompletePersonalDataRequest({
    required this.fullName,
    required this.gender,
    required this.birthDate,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.branch,
    required this.dietType,
    required this.dailyMeals,
    required this.preferredFoods,
    required this.dislikedFoods,
    required this.foodAllergies,
    required this.weeklyWorkouts,
    required this.dailySteps,
    required this.preferredExercises,
    required this.dailyWorkoutHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'birthDate': birthDate,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goal': goal,
      'branch': branch,
      'dietType': dietType,
      'dailyMeals': dailyMeals,
      'preferredFoods': preferredFoods,
      'dislikedFoods': dislikedFoods,
      'foodAllergies': foodAllergies,
      'weeklyWorkouts': weeklyWorkouts,
      'dailySteps': dailySteps,
      'preferredExercises': preferredExercises,
      'dailyWorkoutHours': dailyWorkoutHours,
    };
  }
}

class CompletePersonalDataResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final bool isPersonalDataComplete;
  final bool isSurveyComplete;

  const CompletePersonalDataResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.isPersonalDataComplete,
    required this.isSurveyComplete,
  });

  factory CompletePersonalDataResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final completionStatus = data['completionStatus'] as Map<String, dynamic>;
    return CompletePersonalDataResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      isPersonalDataComplete: completionStatus['isPersonalDataComplete'] as bool? ?? false,
      isSurveyComplete: completionStatus['isSurveyComplete'] as bool? ?? false,
    );
  }
}
