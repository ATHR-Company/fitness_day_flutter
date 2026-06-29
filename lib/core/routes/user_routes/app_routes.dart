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

  // ── User App ─────────────────────────────────────────────
  static const String home = '/user-home';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}
