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
  final String name;
  final String categoryName;
  final String image;
  final int calories;
  final List<IngredientItem> ingredients;
  final List<PreparationStepItem> preparationSteps;
  final List<NutritionItem> nutrition;

  const MealDetailsData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.image,
    required this.calories,
    required this.ingredients,
    required this.preparationSteps,
    required this.nutrition,
  });

  factory MealDetailsData.fromJson(Map<String, dynamic> json) {
    final ingredientsList = json['ingredients'] as List<dynamic>? ?? [];
    final stepsList = json['preparationSteps'] as List<dynamic>? ?? [];
    final nutritionList = json['nutrition'] as List<dynamic>? ?? [];

    return MealDetailsData(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      image: json['image'] as String? ?? '',
      calories: json['calories'] as int? ?? json['calory'] as int? ?? 0,
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
