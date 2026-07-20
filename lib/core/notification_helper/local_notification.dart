import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_helper.dart';

const String _highImportanceChannelId = 'high_importance_channel';
const String _highImportanceChannelName = 'High Importance Notifications';

/// Must be a top-level function — Firebase invokes this in a separate
/// isolate when a data-only message arrives while the app is backgrounded
/// or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase automatically displays the notification when the app is
  // terminated/backgrounded IF the message carries a `notification` payload.
  // A manual local notification is only needed for data-only messages.
  if (message.notification != null) return;

  final title = message.data['title'] ?? '';
  final body = message.data['body'] ?? message.data['message'] ?? '';
  if (title.isEmpty && body.isEmpty) return;

  final plugin = FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await plugin.initialize(initSettings);

  if (Platform.isAndroid) {
    const channel = AndroidNotificationChannel(
      _highImportanceChannelId,
      _highImportanceChannelName,
      importance: Importance.high,
    );
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _highImportanceChannelId,
        _highImportanceChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

/// Sets up foreground/background/terminated push-notification handling:
/// shows a local notification while the app is foregrounded (Android only —
/// iOS displays it natively) and routes taps through [NotificationHelper].
class LocalNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  LocalNotification({required this.navigatorKey});

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!);
              final fakeMessage = RemoteMessage(data: Map<String, dynamic>.from(data));
              NotificationHelper.handleNotificationClick(message: fakeMessage);
            } catch (_) {
              NotificationHelper.handleNotificationClick();
            }
          }
        },
      );
    } catch (e) {
      debugPrint('⚠️ flutterLocalNotificationsPlugin.initialize failed: $e');
    }

    if (Platform.isAndroid) {
      try {
        await _createHighImportanceChannel();
      } catch (e) {
        debugPrint('⚠️ createHighImportanceChannel failed: $e');
      }
    }

    if (Platform.isIOS) {
      // Show alerts/badge/sound while the app is in the foreground.
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Foreground messages — display manually on Android only (iOS shows
    // them natively via setForegroundNotificationPresentationOptions above).
    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isIOS) return;

      try {
        final title = message.notification?.title ?? message.data['title'] ?? '';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        if (title.isEmpty && body.isEmpty) return;

        await _displayNotification(title, body, payload: jsonEncode(message.data));
      } catch (e) {
        debugPrint('⚠️ _displayNotification failed: $e');
      }
    });

    // Tapped a notification while the app was backgrounded.
    _openedAppSub?.cancel();
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationHelper.handleNotificationClick(message: message);
    });

    // App launched by tapping a notification from a terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationHelper.handleNotificationClick(message: initialMessage);
      });
    }
  }

  Future<void> _createHighImportanceChannel() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        _highImportanceChannelId,
        _highImportanceChannelName,
        description: 'This channel is used for high importance notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _displayNotification(String title, String body, {String? payload}) async {
    late NotificationDetails platformDetails;

    if (Platform.isAndroid) {
      const androidDetails = AndroidNotificationDetails(
        _highImportanceChannelId,
        _highImportanceChannelName,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
      platformDetails = const NotificationDetails(android: androidDetails);
    } else {
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      platformDetails = const NotificationDetails(iOS: iosDetails);
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
  }

  Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
