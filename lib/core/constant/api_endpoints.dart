class ApiEndpoints {
  static const String baseUrl = 'https://fitnessday.tech/api';

  /// Socket.IO connects to the root — no /api prefix.
  static const String socketUrl = 'https://fitnessday.tech';

  // ── User Chat ─────────────────────────────────────────────────────────────
  static const String openChat = '/chat/open';
  static const String getChats = '/chat';
  static String getChatMessages(String conversationId) => '/chat/$conversationId/messages';
  /// `POST /chat/:conversationId/media` — multipart/form-data, field: `chat-media`
  static String sendChatMedia(String conversationId) => '/chat/$conversationId/media';

  // ── Specialist Chat ───────────────────────────────────────────────────────
  static const String specialistChats = '/specialist/chat';
  static String openSpecialistChat(String userId) => '/specialist/chat/$userId/open';
  static String getSpecialistChatMessages(String conversationId) => '/specialist/chat/$conversationId/messages';
  static String sendSpecialistChatMedia(String conversationId) => '/specialist/chat/$conversationId/media';

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
  static const String specialistNotifications = '/specialist/notifications';
  static String specialistNotificationRead(String notificationId) =>
      '/specialist/notifications/$notificationId/read';
  static const String notifications = '/notifications';
  static String notificationRead(String notificationId) => '/notifications/$notificationId/read';
  static String specialistAssessmentDetails(String id) => '/specialist/assessment-history/details/$id';
  static String startSpecialistAssessment(String id) => '/specialist/assessment-history/$id/start';
  static String finishSpecialistAssessment(String id) => '/specialist/assessment-history/$id/finish';
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
  static const String usersProfile = '/users/my-profile';
  static const String updateUsersProfile = '/users/update-my-profile';
  static const String usersNotificationsToggle = '/users/notifications/toggle';
  static const String usersLang = '/users/lang';
  static const String changePassword = '/users/change-password';
  static const String changePhoneRequestOtp = '/users/change-phone/request-otp';
  static const String changePhoneVerifyOtp = '/users/change-phone/verify-otp';
  static const String userSignout = '/auth/signout';
  static const String deleteAccount = '/users/delete-account';
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

  // Activity tracking — send progress deltas to backend.
  // The server applies these with $inc, so the payload must be the change
  // since the last acknowledged sync, never a cumulative total.
  static const String syncWalking = '/user-activities/walking/sync';
  static const String syncRunning = '/user-activities/running/sync';

  // Store / Market
  static const String storeHome = '/store/home';
  static const String storeProducts = '/products';
  static String storeProductById(String id) => '/products/$id';
  static const String storePlans = '/plans';
  static String storePlanById(String id) => '/plans/$id';
  static const String storeFavorites = '/favorites';

  // Cart
  static const String cart = '/cart';
  // The line is identified by the item id in the path:
  //   PATCH  /cart/items/:itemIdentity  — body { quantity } (absolute)
  //   DELETE /cart/items/:itemIdentity  — no body
  static String cartItem(String itemIdentity) => '/cart/items/$itemIdentity';
  static const String cartCheckout = '/cart/checkout';
  static String applyOrderCoupon(String orderIdentity) =>
      '/orders/$orderIdentity/coupon';
  static String editOrderDelivery(String orderIdentity) =>
      '/orders/$orderIdentity/delivery';

  // Assessments
  static const String userProgress = '/assessments/progress';
  static const String userAssessments = '/user-assessments';
  static const String assessmentChangeRequests = '/assessment-change-requests';
  static String assessmentDetails(String assessmentId) => '/user-assessments/$assessmentId/details';
  
  // Lookups
  static const String branches = '/lookups/branches';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
}
