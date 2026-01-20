// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // timezone init
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    // ONLY Android init
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (kDebugMode) {
          print("Notification clicked: ${response.payload}");
        }
      },
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Payment reminders',
      description: 'Notifications for upcoming payments',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Payment reminders',
      channelDescription: 'Notifications for upcoming payments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(id, title, body, platformDetails, payload: payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateLocal,
    String? payload,
  }) async {
    final tz.TZDateTime tzDate =
        tz.TZDateTime.from(scheduledDateLocal, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Payment reminders',
      channelDescription: 'Notifications for upcoming payments',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(android: androidDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelNotification(int id) async => _plugin.cancel(id);

  Future<void> cancelAllNotifications() async => _plugin.cancelAll();
}
