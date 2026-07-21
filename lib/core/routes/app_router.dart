import 'package:flutter/material.dart';
import 'package:fitness_day/core/routes/shared/shared_routes.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessments_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/specialist/notifications/presentation/pages/specialist_notifications_page.dart';
import 'package:fitness_day/features/user/notifications/presentation/pages/user_notifications_page.dart';
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
import 'package:fitness_day/features/user/profile/presentation/pages/user_profile_page.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/personal_profile_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/specialist/visits/presentation/pages/visits_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_log_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_details_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/user_upcoming_visit_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/meal_details_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/steps_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/market_main_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_video_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_rest_screen.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/diet_plan_page.dart';
import 'package:fitness_day/features/user/workout/presentation/pages/workout_plan_page.dart';

/// Single combined router — keeps ALL user + specialist routes so that
/// swapping routerConfig is never needed and "Page Not Found" never occurs.
class AppRouter {
  /// Lets code without a BuildContext (e.g. FCM notification-tap handlers)
  /// navigate through the router.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
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
        builder: (context, state) => const SpecialistNotificationsPage(),
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
              signupToken:
                  map['signupToken']?.toString() ??
                  map['resetToken']?.toString(),
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
        builder: (context, state) {
          final resetToken = state.extra?.toString() ?? '';
          return ResetPasswordPage(resetToken: resetToken);
        },
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
        builder: (context, state) => const UserNotificationsPage(),
      ),
      GoRoute(
        path: UserAppRoutes.profile,
        builder: (context, state) => const UserProfilePage(),
      ),
      GoRoute(
        path: UserAppRoutes.store,
        builder: (context, state) => const MarketMainScreen(),
      ),
      GoRoute(
        path: UserAppRoutes.personalProfile,
        builder: (context, state) => const PersonalProfilePage(),
      ),
      GoRoute(
        path: UserAppRoutes.visitLog,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => getIt<AssessmentsCubit>()..fetchAssessmentsForCurrentWeek(),
            ),
            BlocProvider(
              create: (_) => getIt<ChangeAssessmentCubit>(),
            ),
          ],
          child: const VisitLogPage(),
        ),
      ),
      GoRoute(
        path: UserAppRoutes.visitDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final assessmentId = extra['assessmentId'] as String? ?? '';
          final dayNumber = extra['dayNumber'] as int? ?? 1;
          return VisitDetailsPage(
            assessmentId: assessmentId,
            dayNumber: dayNumber,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.upcomingVisitShow,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final assessmentId = extra['assessmentId'] as String? ?? '';
          final dayNumber = extra['dayNumber'] as int? ?? 1;
          return UserUpcomingVisitPage(
            assessmentId: assessmentId,
            dayNumber: dayNumber,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.mealDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final mealId = extra['mealId'] as String? ?? '';
          final assessmentId = extra['assessmentId'] as String? ?? '';
          final dayNumber = extra['dayNumber'] as int? ?? 1;
          return MealDetailsPage(
            mealId: mealId,
            assessmentId: assessmentId,
            dayNumber: dayNumber,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.dietPlan,
        builder: (context, state) => const DietPlanPage(),
      ),
      GoRoute(
        path: UserAppRoutes.workoutPlan,
        builder: (context, state) => const WorkoutPlanPage(),
      ),
      GoRoute(
        path: UserAppRoutes.hydrationDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final assessmentId = extra['assessmentId'] as String? ?? '';
          final dayNumber = extra['dayNumber'] as int? ?? 1;
          final activityId = extra['activityId'] as String? ?? '';
          return HydrationDetailsScreen(
            assessmentId: assessmentId,
            dayNumber: dayNumber,
            activityId: activityId,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.stepsDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final activityType = extra['activityType'] as String? ?? 'walking';
          return StepsDetailsScreen(
            type: activityType == 'running'
                ? ActivityType.running
                : ActivityType.walking,
            assessmentId: extra['assessmentId'] as String? ?? '',
            dayNumber: extra['dayNumber'] as int? ?? 1,
            activityId: extra['activityId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.workoutVideo,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final workoutItemId =
              extra['workoutItemId'] as String? ?? '6a4cf59e38e6d8571647c112';
          final assessmentId = extra['assessmentId'] as String? ?? '';
          final dayNumber = extra['dayNumber'] as int? ?? 1;
          return WorkoutVideoScreen(
            workoutItemId: workoutItemId,
            assessmentId: assessmentId,
            dayNumber: dayNumber,
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.workoutRest,
        builder: (context, state) {
          final restDuration = state.extra as int? ?? 30;
          return WorkoutRestScreen(restDuration: restDuration);
        },
      ),
    ],
  );
}
