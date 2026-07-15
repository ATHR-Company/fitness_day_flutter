class SpecialistMealCategoryModel {
  final String id;
  final String name;
  final int displayOrder;

  SpecialistMealCategoryModel({
    required this.id,
    required this.name,
    required this.displayOrder,
  });

  factory SpecialistMealCategoryModel.fromJson(Map<String, dynamic> json) {
    return SpecialistMealCategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }
}

class SpecialistMealTemplateModel {
  final String id;
  final String name;
  final String mealCategoryId;
  final List<SpecialistTemplateIngredientModel> ingredients;

  SpecialistMealTemplateModel({
    required this.id,
    required this.name,
    required this.mealCategoryId,
    required this.ingredients,
  });

  factory SpecialistMealTemplateModel.fromJson(Map<String, dynamic> json) {
    return SpecialistMealTemplateModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mealCategoryId: json['mealCategoryId'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => SpecialistTemplateIngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SpecialistTemplateIngredientModel {
  final String ingredientId;
  final String name;
  final double defaultWeight;
  final String unit;

  SpecialistTemplateIngredientModel({
    required this.ingredientId,
    required this.name,
    required this.defaultWeight,
    required this.unit,
  });

  factory SpecialistTemplateIngredientModel.fromJson(Map<String, dynamic> json) {
    return SpecialistTemplateIngredientModel(
      ingredientId: json['ingredientId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      defaultWeight: (json['defaultWeight'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
    );
  }
}

class SpecialistActivityLookupModel {
  final String id;
  final String name;
  final String unit;

  SpecialistActivityLookupModel({
    required this.id,
    required this.name,
    required this.unit,
  });

  factory SpecialistActivityLookupModel.fromJson(Map<String, dynamic> json) {
    return SpecialistActivityLookupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
    );
  }
}

class SpecialistExerciseLookupModel {
  final String id;
  final String name;

  SpecialistExerciseLookupModel({
    required this.id,
    required this.name,
  });

  factory SpecialistExerciseLookupModel.fromJson(Map<String, dynamic> json) {
    return SpecialistExerciseLookupModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
