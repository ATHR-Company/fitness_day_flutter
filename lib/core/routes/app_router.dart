import 'package:fitness_day/features/user/user_home/presentation/screens/user_home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/app_routes.dart';
import 'package:fitness_day/features/specialist/auth/presentation/pages/login_page.dart';
import 'package:fitness_day/features/specialist/clients/presentation/pages/clients_page.dart';
import 'package:fitness_day/features/shared/splash/presentation/splash_screen.dart';
import 'package:fitness_day/features/shared/onboarding/presentation/pages/onboarding_page.dart' as fitness_day_onboarding;
import 'package:fitness_day/features/shared/role_selection/presentation/pages/role_selection_page.dart';
import '../../features/specialist/home/presentation/screens/home_page.dart';
import '../../features/shared/notifications/presentation/pages/notifications_page.dart';
import '../../features/shared/visits/presentation/pages/visits_page.dart';
import '../../features/specialist/profile/presentation/pages/profile_page.dart';
import '../../features/specialist/tasks/presentation/pages/today_tasks_page.dart';
import '../../features/user/auth/presentation/pages/login_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/otp_verification_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/reset_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/signup_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/user_info_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.visits,
        builder: (context, state) => const VisitsPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.clients,
        builder: (context, state) => const ClientsPage(),
      ),
      GoRoute(
        path: AppRoutes.todayTasks,
        builder: (context, state) => const TodayTasksPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const fitness_day_onboarding.OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.userLogin,
        builder: (context, state) => const UserLoginPage(),
      ),
      GoRoute(
        path: AppRoutes.userhome,
        builder: (context, state) => const UserHomePage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
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
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.userInfo,
        builder: (context, state) => const UserInfoPage(),
      ),
    ],
  );
}
