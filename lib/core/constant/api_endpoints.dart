class ApiEndpoints {
  static const String baseUrl = 'https://fitnessday.tech/api';
  
  static const String userSignup = '/auth/user/signup';
  static const String userVerifyOtp = '/auth/user/verify-otp';
  static const String userSignin = '/auth/user/signin';
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
  static const String savedArticles = '/articles/saved';

  static String workoutPlanDay(int dayNumber) => '/workout-plan/days/$dayNumber/workouts';
  static String workoutDetails(String workoutItemId) => '/workout-plan/workouts/$workoutItemId';
  static String completeWorkoutSet(int dayNumber, String workoutItemId, int setNumber) =>
      '/workout-plan/days/$dayNumber/workouts/$workoutItemId/sets/$setNumber/complete';
  static String dailyTasks(int dayNumber) => '/daily-tasks/days/$dayNumber';

  // Activity tracking — send progress to backend
  static const String updateWalking = '/activities/walking/progress';
  static const String updateRunning = '/activities/running/progress';
}
