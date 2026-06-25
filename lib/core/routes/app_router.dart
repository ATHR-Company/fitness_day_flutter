import 'package:go_router/go_router.dart';
import 'package:fitness_day/core/routes/app_routes.dart';
import 'package:fitness_day/features/auth/presentation/pages/login_page.dart';
import 'package:fitness_day/features/home/presentation/screens/home_page.dart';
import 'package:fitness_day/features/visits/presentation/pages/visits_page.dart';
import 'package:fitness_day/features/profile/presentation/pages/profile_page.dart';
import 'package:fitness_day/features/notifications/presentation/pages/notifications_page.dart';
import 'package:fitness_day/features/clients/presentation/pages/clients_page.dart';
import 'package:fitness_day/features/tasks/presentation/pages/today_tasks_page.dart';
import 'package:fitness_day/splash_screen.dart';

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
    ],
  );
}
