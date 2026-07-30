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
import 'package:fitness_day/features/user/profile/presentation/pages/user_profile_page.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/personal_profile_page.dart';
import 'package:fitness_day/features/user/progress/presentation/pages/user_progress_page.dart';

import '../../../features/user/auth/presentation/pages/bmi_report_page.dart';
import '../../../features/user/auth/presentation/pages/health_problems_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitness_day/core/injection/injection_container.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/assessments_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/manager/change_assessment_cubit.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_log_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/visit_details_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/user_upcoming_visit_page.dart';
import 'package:fitness_day/features/user/visits/presentation/pages/meal_details_page.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/hydration_details_screen.dart';
import 'package:fitness_day/features/user/user_home/presentation/screens/steps_details_screen.dart';
import 'package:fitness_day/features/user/market/presentation/screens/market_main_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_video_screen.dart';
import 'package:fitness_day/features/user/workout/presentation/screens/workout_rest_screen.dart';
import 'package:fitness_day/features/user/profile/presentation/pages/awards_page.dart';

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
              signupToken: map['signupToken']?.toString() ?? map['resetToken']?.toString(),
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
        path: UserAppRoutes.progress,
        builder: (context, state) => const UserProgressPage(),
      ),
      GoRoute(
        path: UserAppRoutes.visitLog,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => getIt<AssessmentsCubit>()..fetchAssessmentsForCurrentWeek(),
            ),
            BlocProvider(
              create: (context) => getIt<ChangeAssessmentCubit>(),
            ),
          ],
          child: const VisitLogPage(),
        ),
      ),
      GoRoute(
        path: UserAppRoutes.visitDetails,
        builder: (context, state) {
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
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
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
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
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
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
        path: UserAppRoutes.hydrationDetails,
        builder: (context, state) {
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
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
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
          final activityTypeStr = extra['activityType'] as String? ?? 'walking';
          final type = activityTypeStr == 'running'
              ? ActivityType.running
              : ActivityType.walking;
          return StepsDetailsScreen(
            type: type,
            assessmentId: extra['assessmentId'] as String? ?? '',
            dayNumber: extra['dayNumber'] as int? ?? 1,
            activityId: extra['activityId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: UserAppRoutes.workoutVideo,
        builder: (context, state) {
          final extra = (state.extra as Map?)?.cast<String, dynamic>() ?? {};
          final workoutItemId = extra['workoutItemId'] as String? ?? '6a4cf59e38e6d8571647c112';
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
      GoRoute(
        path: UserAppRoutes.awards,
        builder: (context, state) => const AwardsPage(),
      ),
    ],
  );
}
