/// Nutritional breakdown returned by the vision model after it analyses a
/// meal photo.
class MealAnalysisResult {
  /// Empty when the model didn't name the meal — the UI then shows its own
  /// "unknown meal" label, in the current app language.
  final String mealName;
  final List<MealIngredient> ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? notes;

  MealAnalysisResult({
    required this.mealName,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.notes,
  });

  factory MealAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MealAnalysisResult(
      mealName: json['meal_name'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => MealIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      calories: _toDouble(json['calories']),
      protein: _toDouble(json['protein_g']),
      carbs: _toDouble(json['carbs_g']),
      fat: _toDouble(json['fat_g']),
      notes: json['notes'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class MealIngredient {
  final String name;
  final String approxAmount;
  final double calories;

  MealIngredient({
    required this.name,
    required this.approxAmount,
    required this.calories,
  });

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    return MealIngredient(
      name: json['name'] as String? ?? '',
      approxAmount: json['approx_amount'] as String? ?? '',
      calories: MealAnalysisResult._toDouble(json['calories']),
    );
  }
}
