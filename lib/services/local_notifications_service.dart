import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'eeloo',
      'eeloo channel',
      channelDescription: 'this is eeloo channel',
      icon: 'icon',
      importance: Importance.max,
      priority: Priority.max,
    ),
    iOS: IOSNotificationDetails(),
  );

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('icon'),
      iOS: IOSInitializationSettings(),
    );

    _notificationsPlugin.initialize(initializationSettings);
  }

  static void scheduleNotification(
    String senderUsername,
    int notificationId,
    TZDateTime scheduledDate,
  ) async {
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'eeloo',
      'hai 1 ora per rispondere a $senderUsername',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static void deleteScheduledNotification(notificationId) async {
    FlutterLocalNotificationsPlugin().cancel(notificationId);
  }

  static void display(RemoteMessage message) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.show(
      id,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }
}
