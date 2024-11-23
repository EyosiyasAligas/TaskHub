import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AwesomeNotificationService {
  AwesomeNotificationService._privateConstructor();
  static final AwesomeNotificationService instance = AwesomeNotificationService._privateConstructor();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Initialize Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications.',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
        ),
      ],
    );

    // print the device token
    _firebaseMessaging.getToken().then((token) {
      if (kDebugMode) {
        print('Device Token: $token');
      }
    });

    // Request permissions and set up FCM
    requestPermission();
    setupFirebaseMessaging();
  }

  Future<void> requestPermission() async {
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void setupFirebaseMessaging() {
    // Handle foreground notifications

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingNotification(message);
    });

    // Handle background and terminated state notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleIncomingNotification(message);
    });
  }

  Future<void> handleIncomingNotification(RemoteMessage message) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: 'high_importance_channel',
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? 'You have a new message.',
      ),
    );
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String channelKey = 'high_importance_channel',
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
      ),
    );
  }

  void cancelNotification(int id) {
    AwesomeNotifications().cancel(id);
  }

  void cancelAllNotifications() {
    AwesomeNotifications().cancelAll();
  }
}
