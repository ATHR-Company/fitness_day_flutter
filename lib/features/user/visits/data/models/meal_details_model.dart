class MealDetailsResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final MealDetailsData data;

  const MealDetailsResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory MealDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return MealDetailsResponseModel(
      success: json['success'] as bool,
      statusCode: json['statusCode'] as int,
      message: json['message'] as String,
      data: MealDetailsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class MealDetailsData {
  final String id;
  final String assessmentId;
  final int dayNumber;
  final String name;
  final String categoryName;
  final String image;
  final bool isCompleted;
  final bool canEdit;
  final double calories;
  final String time;
  final List<IngredientItem> ingredients;
  final List<PreparationStepItem> preparationSteps;
  final List<NutritionItem> nutrition;

  const MealDetailsData({
    required this.id,
    required this.assessmentId,
    required this.dayNumber,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.isCompleted,
    required this.canEdit,
    required this.calories,
    this.time = '',
    required this.ingredients,
    required this.preparationSteps,
    required this.nutrition,
  });

  MealDetailsData copyWith({
    String? id,
    String? assessmentId,
    int? dayNumber,
    String? name,
    String? categoryName,
    String? image,
    bool? isCompleted,
    bool? canEdit,
    double? calories,
    String? time,
    List<IngredientItem>? ingredients,
    List<PreparationStepItem>? preparationSteps,
    List<NutritionItem>? nutrition,
  }) {
    return MealDetailsData(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      categoryName: categoryName ?? this.categoryName,
      image: image ?? this.image,
      isCompleted: isCompleted ?? this.isCompleted,
      canEdit: canEdit ?? this.canEdit,
      calories: calories ?? this.calories,
      time: time ?? this.time,
      ingredients: ingredients ?? this.ingredients,
      preparationSteps: preparationSteps ?? this.preparationSteps,
      nutrition: nutrition ?? this.nutrition,
    );
  }

  factory MealDetailsData.fromJson(Map<String, dynamic> json) {
    final ingredientsList = json['ingredients'] as List<dynamic>? ?? [];
    final stepsList = json['preparationSteps'] as List<dynamic>? ?? [];
    final nutritionList = json['nutrition'] as List<dynamic>? ?? [];

    return MealDetailsData(
      id: json['mealId'] as String? ?? json['id'] as String? ?? json['_id'] as String? ?? '',
      assessmentId: json['assessmentId'] as String? ?? '',
      dayNumber: json['dayNumber'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      calories: (json['calories'] as num?)?.toDouble() ?? (json['calory'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] as String? ?? '',
      ingredients: ingredientsList
          .map((item) => IngredientItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      preparationSteps: stepsList
          .map((item) => PreparationStepItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      nutrition: nutritionList
          .map((item) => NutritionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class IngredientItem {
  final String name;
  final double quantity;
  final String unit;

  const IngredientItem({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }
}

class PreparationStepItem {
  final int order;
  final String text;

  const PreparationStepItem({
    required this.order,
    required this.text,
  });

  factory PreparationStepItem.fromJson(Map<String, dynamic> json) {
    return PreparationStepItem(
      order: json['order'] as int? ?? 1,
      text: json['text'] as String? ?? '',
    );
  }
}

class NutritionItem {
  final String key;
  final double value;

  const NutritionItem({
    required this.key,
    required this.value,
  });

  factory NutritionItem.fromJson(Map<String, dynamic> json) {
    return NutritionItem(
      key: json['key'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
