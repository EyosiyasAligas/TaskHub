import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (message != null) return;
  print('Title: ${message.notification!.title}');
  print('Body: ${message.notification!.body}');
  print('Payload: ${message.data}');
}

Future<void> handleForgroundMessage(RemoteMessage message) async {
  if (message != null) return;
  print('Title: ${message.notification!.title}');
  print('Body: ${message.notification!.body}');
  print('Payload: ${message.data}');
}

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _messageStreamController = BehaviorSubject<RemoteMessage>();

  // final _androidChannel = const AndroidNotificationChannel(
  //   'high_importance_channel',
  //   'High Importance Notifications',
  //   description: 'This channel is used for important notifications',
  //   importance: Importance.high,
  //   playSound: true,
  // );
  //
  // final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  handleMessages(RemoteMessage message) async {
    // if (message.notification != null) return;
    // message.notification.
    // final shipmentProvider = Provider.of<ShipmentProvider>(
    //     navigatorKey.currentContext!,
    //     listen: false);
    // print('Shipid' + message.data['id'].toString());
    // var shipmentId = message.data['id'];
    // final fetchedShipment = await shipmentProvider.fetchShipmentById(
    //   shipmentId.toString(),
    // );
    // print('fetchedShipment $fetchedShipment');
    // if (fetchedShipment != null) {
    //   navigatorKey.currentState!.push(
    //     MaterialPageRoute(
    //       builder: (context) => ShipmentDetailsScreen(shipment: fetchedShipment),
    //     ),
    //   );
    // }
  }

  Future initLocalNotification() async {
    // final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // // final iOS = IOSInitilaizationSettings();
    // final initializationSettings = InitializationSettings(android: android);
    // await _localNotificationsPlugin.initialize(
      // initializationSettings,
      // onDidReceiveNotificationResponse: (payload) async {
      //   if (payload != null) {
      //     final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
      //     handleMessages(message);
      //   }
      // },
    // );
    // final platform =
    // _localNotificationsPlugin.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>();
    // await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        handleMessages(message);
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      handleMessages(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessages(message);
    });
    FirebaseMessaging.onBackgroundMessage(
            (message) => handleBackgroundMessage(message));
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        // _localNotificationsPlugin.show(
        //     notification.hashCode,
        //     notification.title,
        //     notification.body,
        //     // NotificationDetails(
        //     //   android: AndroidNotificationDetails(
        //     //       _androidChannel.id, _androidChannel.name,
        //     //       channelDescription: _androidChannel.description,
        //     //       importance: _androidChannel.importance,
        //     //       playSound: _androidChannel.playSound,
        //     //       icon: '@drawable/ic_launcher'),
        //     // ),
        //     payload: jsonEncode(message.toMap()));
      } else {
        return;
      }
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('TokenFCM $fcmToken');
    initPushNotification();
    initLocalNotification();
  }
}
