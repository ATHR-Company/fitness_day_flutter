import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'package:fitness_day/fitness_day.dart';
import 'package:fitness_day/core/routes/app_router.dart';
import 'package:fitness_day/core/routes/specialist_routes/app_routes.dart';
import 'package:fitness_day/core/routes/user_routes/app_routes.dart';
import 'package:fitness_day/features/shared/conversations/presentation/pages/chat_details_page.dart';

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

      // Chat pushes are deliberately not written to the notifications list —
      // the unread badge on the conversation is their record — so sending the
      // tap there would open a screen that never shows the message.
      final String? type = message.data['type'] as String?;
      final String? conversationId = message.data['conversationId'] as String?;
      if (type == 'chat' && conversationId != null && conversationId.isNotEmpty) {
        debugPrint('📩 Chat notification tapped → conversation $conversationId');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatDetailsPage(
              // No `title` on purpose. The push headline is a notification
              // string, not the other party's name, and [ChatHeader] gives a
              // passed-in title priority over the name that comes back with
              // the messages response — so passing it here pinned the wrong
              // name on the conversation for as long as it stayed open.
              isSpecialist: true,
              conversationId: conversationId,
              specialistId: message.data['senderId'] as String?,
              isSpecialistMode: role == AppRole.specialist,
            ),
          ),
        );
        return;
      }

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
