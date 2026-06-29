import 'package:fitness_day/core/routes/shared/shared_routes.dart';

class UserAppRoutes extends SharedRoutes {
  // ── User Auth ────────────────────────────────────────────
  static const String login = '/user-login';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String resetPassword = '/reset-password';
  static const String signUp = '/sign-up';
  static const String userInfo = '/user-info';

  // ── User App ─────────────────────────────────────────────
  static const String home = '/user-home';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String store = '/store';
  static const String shareWithFriends = '/share-with-friends';
  static const String visitLog = '/visit-log';
  static const String dietPlan = '/diet-plan';
  static const String workoutPlan = '/workout-plan';
}
