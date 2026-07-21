import 'package:fitness_day/core/routes/shared/shared_routes.dart';

class SpecialistAppRoutes extends SharedRoutes {
  // ── Specialist Auth ─────────────────────────────────────
  static const String login = '/login';

  // ── Specialist App ──────────────────────────────────────
  static const String home = '/home';
  static const String visits = '/visits';
  static const String profile = '/profile';
  static const String notifications = '/specialist-notifications';
  static const String clients = '/clients';
  static const String todayTasks = '/today-tasks';
}
