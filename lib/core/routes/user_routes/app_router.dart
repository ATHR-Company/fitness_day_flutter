import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/splash/presentation/splash_screen.dart';
import 'package:fitness_day/features/shared/onboarding/presentation/pages/onboarding_page.dart'
    as onboarding;
import 'package:fitness_day/features/shared/role_selection/presentation/pages/role_selection_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/login_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/otp_verification_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/reset_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/signup_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/user_info_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/fitness_system_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/diet_system_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/home_page.dart';
import 'package:fitness_day/features/shared/notifications/presentation/pages/notifications_page.dart';
import 'package:fitness_day/features/specialist/profile/presentation/pages/profile_page.dart';

import '../../../features/user/auth/presentation/pages/bmi_report_page.dart';
import '../../../features/user/auth/presentation/pages/health_problems_page.dart';

class UserAppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: SharedRoutes.splash,
    routes: [
      // ── Shared ────────────────────────────────────────────
      GoRoute(
        path: SharedRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: SharedRoutes.onboarding,
        builder: (context, state) => const onboarding.OnboardingPage(),
      ),
      GoRoute(
        path: SharedRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // ── User Auth ──────────────────────────────────────────
      GoRoute(
        path: UserAppRoutes.login,
        builder: (context, state) => const UserLoginPage(),
      ),
      GoRoute(
        path: UserAppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: UserAppRoutes.otpVerification,
        builder: (context, state) {
          if (state.extra is Map) {
            final map = state.extra as Map;
            return OtpVerificationPage(
              phoneNumber: map['phoneNumber']?.toString() ?? '',
              isForgotPassword: map['isForgotPassword'] as bool? ?? false,
            );
          }
          return OtpVerificationPage(
            phoneNumber: state.extra?.toString() ?? '',
            isForgotPassword: true,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: UserAppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: UserAppRoutes.userInfo,
        builder: (context, state) => const UserInfoPage(),
      ),
      GoRoute(
        path: UserAppRoutes.fitnessSystem,
        builder: (context, state) => const FitnessSystemPage(),
      ),
      GoRoute(
        path: UserAppRoutes.dietSystem,
        builder: (context, state) => const DietSystemPage(),
      ),
      GoRoute(
        path: UserAppRoutes.healthProblems,
        builder: (context, state) => const HealthProblemsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.bmiReport,
        builder: (context, state) => const BmiReportPage(),
      ),

      // ── User App ───────────────────────────────────────────
      GoRoute(
        path: UserAppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: UserAppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
