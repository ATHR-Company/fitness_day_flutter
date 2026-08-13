import 'package:fitness_day/core/routes/shared/shared_routes.dart';

class UserAppRoutes extends SharedRoutes {
  // ── User Auth ────────────────────────────────────────────
  static const String login = '/user-login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String signUp = '/sign-up';
  static const String userInfo = '/user-info';
  static const String fitnessSystem = '/fitness-system';
  static const String dietSystem = '/diet-system';
  static const String healthProblems = '/health-problems';
  static const String bmiReport = '/bmi-report';

  // ── User App ─────────────────────────────────────────────
  static const String home = '/user-home';
  static const String notifications = '/notifications';
  static const String profile = '/user-profile';
  static const String personalProfile = '/personal-profile';
  static const String progress = '/user-progress';
  static const String challenges = '/challenges';
  static const String scanMeal = '/scan-meal';
  static const String store = '/store';
  static const String shareWithFriends = '/share-with-friends';
  static const String visitLog = '/visit-log';
  static const String visitDetails = '/visit-details';
  static const String upcomingVisitShow = '/upcoming-visit-show';
  static const String dietPlan = '/diet-plan';
  static const String mealDetails = '/meal-details';
  static const String workoutPlan = '/workout-plan';
  static const String hydrationDetails = '/hydration-details';
  static const String stepsDetails = '/steps-details';
  static const String workoutVideo = '/workout-video';
  static const String workoutRest = '/workout-rest';
  static const String awards = '/awards';
  static const String achievements = '/achievements';

  /// The full badge wall, locked ones included. Separate from [achievements],
  /// which is the day-strip view of what was unlocked on a given date.
  static const String achievementsWall = '/achievements-wall';

  // ── App Link entry points ────────────────────────────────
  // Reached from https://fitnessday.tech/... links shared outside the app.
  // Keep in sync with the intent-filter in AndroidManifest.xml and the paths
  // in .well-known/apple-app-site-association.

  /// Shared product link. `/products/:id` is what [AppShareLinks.product]
  /// builds; `/store/products/:id` is accepted too so older shared links and
  /// anything the website links to keep working.
  static const String productDetails = '/products/:id';
  static const String storeProductDetails = '/store/products/:id';

  /// Generic "open the app" link — used in emails and push payloads that only
  /// need to bring the user to the home screen.
  static const String openApp = '/open';

  static String productDetailsPath(String id) => '/products/$id';
}
