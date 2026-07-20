import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/fitness_day.dart';
import 'package:fitness_day/core/routes/app_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';

/// Handles what happens when the user taps a push notification —
/// foreground, background, or from a terminated app.
class NotificationHelper {
  const NotificationHelper._();

  static Future<void> handleNotificationClick({RemoteMessage? message}) async {
    try {
      if (message == null) return;

      final context = AppRouter.navigatorKey.currentContext;
      if (context == null) {
        debugPrint('❌ NotificationHelper: no navigator context available');
        return;
      }

      final role = RoleNotifier.instance.value;
      final path = role == AppRole.specialist
          ? SpecialistAppRoutes.notifications
          : UserAppRoutes.notifications;

      debugPrint('📩 Notification tapped, opening: $path');
      context.push(path);
    } catch (e) {
      debugPrint('❌ Error handling notification click: $e');
    }
  }
}
