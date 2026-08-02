class DietPlanResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final DietPlanData? data;

  const DietPlanResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory DietPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return DietPlanResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: json['data'] != null
          ? DietPlanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DietPlanData {
  final String assessmentId;
  final int dayNumber;
  final List<MealItem> meals;

  const DietPlanData({
    required this.assessmentId,
    required this.dayNumber,
    required this.meals,
  });

  factory DietPlanData.fromJson(Map<String, dynamic> json) {
    final mealsList = json['meals'] as List<dynamic>? ?? [];
    return DietPlanData(
      assessmentId: json['assessmentId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      meals: mealsList
          .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  DietPlanData copyWith({List<MealItem>? meals}) {
    return DietPlanData(
      assessmentId: assessmentId,
      dayNumber: dayNumber,
      meals: meals ?? this.meals,
    );
  }
}

class MealItem {
  final String id;
  final String name;
  final String categoryName;
  final String image;
  final double calories;
  final String time;
  final bool isCompleted;

  const MealItem({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.calories,
    required this.time,
    required this.isCompleted,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['mealId'] as String? ?? json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? (json['calory'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  MealItem copyWith({bool? isCompleted}) {
    return MealItem(
      id: id,
      name: name,
      categoryName: categoryName,
      image: image,
      calories: calories,
      time: time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
