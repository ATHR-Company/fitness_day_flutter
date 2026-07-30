/// The instruction sent to the vision model alongside a meal photo.
///
/// The JSON schema is fixed so [MealAnalysisResult.fromJson] can always parse
/// it; only the free-text values follow [languageCode], so the user never gets
/// a result in a language they didn't pick.
String buildMealAnalysisPrompt(String languageCode) {
  final String answerLanguage = languageCode == 'ar' ? 'Arabic' : 'English';

  return '''
You are a nutrition expert. Analyse the attached meal photo and return an
accurate nutritional breakdown.

Reply with valid JSON only — no extra prose and no markdown fences — in
exactly this shape:
{
  "meal_name": "the meal name in $answerLanguage",
  "ingredients": [
    {"name": "ingredient name in $answerLanguage", "approx_amount": "approximate amount, e.g. 150 g", "calories": 0}
  ],
  "calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "notes": "any important note about the accuracy of the estimate or unclear ingredients, in $answerLanguage"
}

Every free-text value must be written in $answerLanguage.
If you cannot clearly identify the food, say so in "notes" and give your best
possible guess.
All numbers must be numeric values, not strings.
''';
}
