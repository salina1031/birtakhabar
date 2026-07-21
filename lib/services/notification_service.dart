import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps Firebase Cloud Messaging so emergency alerts and news updates reach
/// users as push notifications, per the "Third-Party Integration Layer" in
/// the system architecture.
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _local.initialize(initSettings);

    // Foreground messages: show a local notification since FCM does not
    // auto-display foreground pushes on Android.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'birta_khabar_alerts',
              'BirtaKhabar Alerts',
              channelDescription: 'News and emergency alert notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  /// Returns the device FCM token, used server-side (Cloud Functions) to
  /// target notifications by subscribed topic/category.
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribes the device to a category topic (e.g. "emergency", "local")
  /// so category-based alerts (see notificationPrefs on AppUser) can be sent
  /// via FCM topic messaging without a per-user fan-out.
  Future<void> subscribeToCategory(String category) =>
      _messaging.subscribeToTopic(category);

  Future<void> unsubscribeFromCategory(String category) =>
      _messaging.unsubscribeFromTopic(category);
}
