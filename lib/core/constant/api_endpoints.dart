class ApiEndpoints {
  static const String baseUrl = 'https://fitnessday.tech/api';
  
  static const String userSignup = '/auth/user/signup';
  static const String userVerifyOtp = '/auth/user/verify-otp';
  static const String userSignin = '/auth/user/signin';
  static const String specialistSignin = '/auth/specialist/signin';
  static const String specialistSignout = '/auth/specialist/signout';
  static const String specialistHome = '/specialist-home';
  static const String specialistProfile = '/specialist/my-profile';
  static const String updateSpecialistProfile = '/specialist/update-my-profile';
  static const String specialistClients = '/specialist/clients';
  static const String specialistDailyTasks = '/specialist/daily-tasks';
  static const String specialistAssessmentHistory = '/specialist/assessment-history';
  static String specialistAssessmentDetails(String id) => '/specialist/assessment-history/details/$id';
  static String startSpecialistAssessment(String id) => '/specialist/assessment-history/$id/start';
  static String updateSpecialistAssessmentGoal(String id) => '/specialist/assessment-history/$id/goal';
  static String updateSpecialistAssessmentHealthReport(String id) => '/specialist/assessment-history/$id/health-report';
  static String updateSpecialistAssessmentPlan(String assessmentId, int dayNumber) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/plan';
  static String addSpecialistDayMeal(String assessmentId, int dayNumber) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/meals';
  static String updateSpecialistDayMeal(String assessmentId, int dayNumber, String mealId) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/meals/$mealId';
  static String addSpecialistDayWorkout(String assessmentId, int dayNumber) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/workouts';
  static String updateSpecialistDayWorkout(String assessmentId, int dayNumber, String workoutItemId) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/workouts/$workoutItemId';
  static String addSpecialistDayActivity(String assessmentId, int dayNumber) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/activities';
  static String updateSpecialistDayActivity(String assessmentId, int dayNumber, String activityItemId) =>
      '/specialist/assessments/$assessmentId/days/$dayNumber/activities/$activityItemId';
  static const String specialistMealCategories = '/specialist/assessments/meal-categories';
  static String specialistMealTemplates(String categoryId) =>
      '/specialist/assessments/meal-templates?mealCategoryId=$categoryId';
  static const String specialistActivities = '/specialist/assessments/activities';
  static const String specialistExercises = '/specialist/assessments/exercises';
  static String specialistClientProfile(String userId) => '/specialist/clients/$userId/profile';
  static String specialistClientUpcomingAssessments(String userId) => '/specialist/clients/$userId/assessments/upcoming';
  static String specialistClientPreviousAssessments(String userId) => '/specialist/clients/$userId/assessments/previous';
  static String specialistClientProgress(String userId) => '/specialist/clients/$userId/progress';
  static const String forgotPasswordSendOtp = '/auth/forgot-password/send-otp';
  static const String forgotPasswordVerifyOtp = '/auth/forgot-password/verify-otp';
  static const String forgotPasswordReset = '/auth/forgot-password/reset';
  static const String forgotPasswordResendOtp = '/auth/forgot-password/resend-otp';
  static const String userLookups = '/lookups/user';
  static const String healthQuestions = '/health-questions';
  static const String completePersonalData = '/users/complete-personal-data';
  static const String submitHealthAnswers = '/users/submit-health-answers';
  static const String authRefresh = '/auth/refresh';
  static const String socialAuth = '/auth/social';
  static const String dietPlan = '/diet-plan';
  static const String mealDetails = '/diet-plan/meals';

  static String mealDetailsNew(String assessmentId, int dayNumber, String mealId) =>
      '/diet-plan/assessment/$assessmentId/days/$dayNumber/meals/$mealId';
  static String activityDetails(String assessmentId, int dayNumber, String activityId) =>
      '/user-activities/assessments/$assessmentId/days/$dayNumber/activities/$activityId';

  static String hydrationIncrease(String assessmentId, int dayNumber, String activityId) =>
      '/user-activities/assessments/$assessmentId/days/$dayNumber/activities/$activityId/hydration/increase';

  static String hydrationDecrease(String assessmentId, int dayNumber, String activityId) =>
      '/user-activities/assessments/$assessmentId/days/$dayNumber/activities/$activityId/hydration/decrease';
  static const String savedArticles = '/articles/saved';

  static String workoutPlanDay(int dayNumber) => '/workout-plan/days/$dayNumber/workouts';
  static String workoutDetails(String assessmentId, int dayNumber, String workoutItemId) =>
      '/workout-plan/assessments/$assessmentId/days/$dayNumber/workouts/$workoutItemId';
  static String completeWorkoutSet(String assessmentId, int dayNumber, String workoutItemId, int setNumber) =>
      '/workout-plan/assessments/$assessmentId/days/$dayNumber/workouts/$workoutItemId/sets/$setNumber/complete';
  static String dailyTasks(int dayNumber) => '/daily-tasks/days/$dayNumber';

  // Activity tracking — send progress to backend
  static const String updateWalking = '/activities/walking/progress';
  static const String updateRunning = '/activities/running/progress';

  // Store / Market
  static const String storeHome = '/store/home';
  static const String storeProducts = '/products';
  static String storeProductById(String id) => '/products/$id';
  static const String storePlans = '/plans';
  static String storePlanById(String id) => '/plans/$id';
  static const String storeFavorites = '/favorites';

  // Assessments
  static const String userAssessments = '/user-assessments';
  static const String assessmentChangeRequests = '/assessment-change-requests';
  static String assessmentDetails(String assessmentId) => '/user-assessments/$assessmentId/details';
  
  // Lookups
  static const String branches = '/lookups/branches';
}
