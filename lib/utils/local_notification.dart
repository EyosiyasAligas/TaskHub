import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationService {
  LocalNotificationService._privateConstructor();
  static final LocalNotificationService instance = LocalNotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Cache for displayed notification IDs to prevent duplicates
  final Set<int> _displayedNotifications = {};

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    setupFirebaseMessaging();
  }

  /// Setup Firebase Messaging for foreground and opened notifications
  void setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showFirebaseNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation or actions here
      print("Notification opened: ${message.notification?.title}");
    });
  }

  /// Show notification, avoiding duplicates
  Future<void> showFirebaseNotification(RemoteMessage message) async {
    final int notificationId = message.hashCode;

    if (_displayedNotifications.contains(notificationId)) {
      return; // Avoid duplicate notifications
    }

    _displayedNotifications.add(notificationId);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'High_Importance_Channel',
      'High Importance Channel',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  /// Show custom local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Cancel a specific notification
  void cancelNotification(int id) {
    _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  void cancelAllNotifications() {
    _flutterLocalNotificationsPlugin.cancelAll();
  }
}
