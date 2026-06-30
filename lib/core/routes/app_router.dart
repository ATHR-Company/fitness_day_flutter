import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/notifications/presentation/pages/notifications_page.dart';
import 'package:fitness_day/features/shared/onboarding/presentation/pages/onboarding_page.dart'
    as onboarding;
import 'package:fitness_day/features/shared/role_selection/presentation/pages/role_selection_page.dart';
import 'package:fitness_day/features/shared/splash/presentation/splash_screen.dart';
import 'package:fitness_day/features/specialist/auth/presentation/pages/login_page.dart'
    as specialist_login;
import 'package:fitness_day/features/specialist/clients/presentation/pages/clients_page.dart';
import 'package:fitness_day/features/specialist/home/presentation/screens/home_page.dart'
    as specialist_home;
import 'package:fitness_day/features/specialist/profile/presentation/pages/profile_page.dart'
    as specialist_profile;
import 'package:fitness_day/features/specialist/tasks/presentation/pages/today_tasks_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/diet_system_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/fitness_system_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/health_problems_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/bmi_report_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/forgot_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/login_page.dart'
    as user_login;
import 'package:fitness_day/features/user/auth/presentation/pages/otp_verification_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/reset_password_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/signup_page.dart';
import 'package:fitness_day/features/user/auth/presentation/pages/user_info_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/home_page.dart'
    as user_home;
import 'package:fitness_day/features/specialist/profile/presentation/pages/profile_page.dart'
    as user_profile;
import 'package:go_router/go_router.dart';

import '../../features/specialist/visits/presentation/pages/visits_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_log_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_details_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/user_upcoming_visit_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/meal_details_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_video_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_rest_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_map_screen.dart';
/// Single combined router — keeps ALL user + specialist routes so that
/// swapping routerConfig is never needed and "Page Not Found" never occurs.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: SharedRoutes.splash,
    routes: [
      // ── Shared ────────────────────────────────────────────────────────────
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

      // ── Specialist Auth ───────────────────────────────────────────────────
      GoRoute(
        path: SpecialistAppRoutes.login,
        builder: (context, state) => const specialist_login.LoginPage(),
      ),

      // ── Specialist App ────────────────────────────────────────────────────
      GoRoute(
        path: SpecialistAppRoutes.home,
        builder: (context, state) => const specialist_home.HomePage(),
      ),
      GoRoute(
        path: SpecialistAppRoutes.visits,
        builder: (context, state) => const VisitsPage(),
      ),
      GoRoute(
        path: SpecialistAppRoutes.profile,
        builder: (context, state) => const specialist_profile.ProfilePage(),
      ),
      GoRoute(
        path: SpecialistAppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: SpecialistAppRoutes.clients,
        builder: (context, state) => const ClientsPage(),
      ),
      GoRoute(
        path: SpecialistAppRoutes.todayTasks,
        builder: (context, state) => const TodayTasksPage(),
      ),

      // ── User Auth ─────────────────────────────────────────────────────────
      GoRoute(
        path: UserAppRoutes.login,
        builder: (context, state) => const user_login.UserLoginPage(),
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
            isForgotPassword: false,
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
        path: UserAppRoutes.dietSystem,
        builder: (context, state) => const DietSystemPage(),
      ),
      GoRoute(
        path: UserAppRoutes.fitnessSystem,
        builder: (context, state) => const FitnessSystemPage(),
      ),
      GoRoute(
        path: UserAppRoutes.healthProblems,
        builder: (context, state) => const HealthProblemsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.bmiReport,
        builder: (context, state) => const BmiReportPage(),
      ),

      // ── User App ──────────────────────────────────────────────────────────
      GoRoute(
        path: UserAppRoutes.home,
        builder: (context, state) => const user_home.HomePage(),
      ),
      GoRoute(
        path: UserAppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.profile,
        builder: (context, state) => const user_profile.ProfilePage(),
      ),
      GoRoute(
        path: UserAppRoutes.visitLog,
        builder: (context, state) => const VisitLogPage(),
      ),
      GoRoute(
        path: UserAppRoutes.visitDetails,
        builder: (context, state) => const VisitDetailsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.upcomingVisitShow,
        builder: (context, state) => const UserUpcomingVisitPage(),
      ),
      GoRoute(
        path: UserAppRoutes.mealDetails,
        builder: (context, state) => const MealDetailsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.hydrationDetails,
        builder: (context, state) => const HydrationDetailsScreen(),
      ),
      GoRoute(
        path: UserAppRoutes.workoutVideo,
        builder: (context, state) => const WorkoutVideoScreen(),
      ),
      GoRoute(
        path: UserAppRoutes.workoutRest,
        builder: (context, state) => const WorkoutRestScreen(),
      ),
      GoRoute(
        path: UserAppRoutes.workoutMap,
        builder: (context, state) => const WorkoutMapScreen(),
      ),
    ],
  );
}
