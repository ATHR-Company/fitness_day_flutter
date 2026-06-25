import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/app_routes.dart';
import 'package:fitness_day/features/specialist/auth/presentation/pages/login_page.dart';
import 'package:fitness_day/features/specialist/clients/presentation/pages/clients_page.dart';
import 'package:fitness_day/features/shared/splash/presentation/splash_screen.dart';
import 'package:fitness_day/features/shared/onboarding/presentation/pages/onboarding_page.dart' as fitness_day_onboarding;

import '../../features/specialist/home/presentation/screens/home_page.dart';
import '../../features/shared/notifications/presentation/pages/notifications_page.dart';
import '../../features/shared/visits/presentation/pages/visits_page.dart';
import '../../features/specialist/profile/presentation/pages/profile_page.dart';
import '../../features/specialist/tasks/presentation/pages/today_tasks_page.dart';

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
    ],
  );
}
