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
  final int dayNumber;
  final List<MealItem> meals;

  const DietPlanData({
    required this.dayNumber,
    required this.meals,
  });

  factory DietPlanData.fromJson(Map<String, dynamic> json) {
    final mealsList = json['meals'] as List<dynamic>? ?? [];
    return DietPlanData(
      dayNumber: json['dayNumber'] as int? ?? 1,
      meals: mealsList
          .map((item) => MealItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MealItem {
  final String id;
  final String name;
  final String categoryName;
  final String image;
  final int calories;

  const MealItem({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.calories,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      calories: json['calories'] as int? ?? json['calory'] as int? ?? 0,
    );
  }
}
