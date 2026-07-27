/// The three screens that together build `POST /users/complete-personal-data`.
/// A validation error can belong to any of them, even though the request is
/// only sent from the last one.
enum ProfileSetupStep { personalInfo, diet, fitness }

/// Field keys the backend returns in `{"message": "...", "key": "..."}` when
/// `POST /users/complete-personal-data` rejects a value.
///
/// Mirrors the server's `ProfileValidationKey` enum one-to-one.
enum ProfileValidationKey {
  fullName('FULL_NAME', ProfileSetupStep.personalInfo),
  gender('GENDER', ProfileSetupStep.personalInfo),
  birthDate('BIRTH_DATE', ProfileSetupStep.personalInfo),
  height('HEIGHT', ProfileSetupStep.personalInfo),
  weight('WEIGHT', ProfileSetupStep.personalInfo),
  activityLevel('ACTIVITY_LEVEL', ProfileSetupStep.personalInfo),
  goal('GOAL', ProfileSetupStep.personalInfo),
  branch('BRANCH', ProfileSetupStep.personalInfo),

  dietType('DIET_TYPE', ProfileSetupStep.diet),
  dailyMeals('DAILY_MEALS', ProfileSetupStep.diet),
  preferredFoods('PREFERRED_FOODS', ProfileSetupStep.diet),
  dislikedFoods('DISLIKED_FOODS', ProfileSetupStep.diet),
  foodAllergies('FOOD_ALLERGIES', ProfileSetupStep.diet),

  weeklyWorkouts('WEEKLY_WORKOUTS', ProfileSetupStep.fitness),
  dailySteps('DAILY_STEPS', ProfileSetupStep.fitness),
  preferredExercises('PREFERRED_EXERCISES', ProfileSetupStep.fitness),
  dailyWorkoutHours('DAILY_WORKOUT_HOURS', ProfileSetupStep.fitness);

  /// The value as it arrives from the API.
  final String apiValue;

  /// Which onboarding screen owns the input for this key.
  final ProfileSetupStep step;

  const ProfileValidationKey(this.apiValue, this.step);

  /// Returns `null` for unknown/absent keys, so a new backend key just falls
  /// back to the generic error message instead of breaking the screen.
  static ProfileValidationKey? fromApi(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final key in ProfileValidationKey.values) {
      if (key.apiValue == raw) return key;
    }
    return null;
  }
}
