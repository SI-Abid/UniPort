import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniport/version_1/services/providers.dart';

class LocalNotification {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> requestNotificationPermission() async {
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      // * FOR ANDROID
      // print('User granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      // * FOR IOS
      // print('User granted provisional permission');
    } else {
      AppSettings.openNotificationSettings();
    }
  }

  static Future<String?> getToken() async {
    // * if WEB provide vapidkey
    return await messaging.getToken();
  }

  static void listenForTokenRefresh() {
    messaging.onTokenRefresh.listen((token) {
      loggedInUser.updatePushToken(token);
    });
  }

  static Future<void> initialize([BuildContext? context]) async {
    // await FirebaseMessaging.instance.setAutoInitEnabled(true);
    await requestNotificationPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
    FirebaseMessaging.onMessage.listen((message) {
      print('App in foreground: $message');
      if (message.notification != null) {
        print('Notification: ${message.data['sender']}');
        print('Notification: ${loggedInUser.openedChatId}');
        if (message.data['sender'] != loggedInUser.openedChatId) {
          showNotification(message);
        }
      }
    });
    // FirebaseMessaging.instance;
    // FirebaseMessaging.onBackgroundMessage((message) async {
    //   print('App in background: $message');
    //   if (message.notification != null) {
    //     print('Notification: ${message.notification!.title}');
    //     showNotification(message);
    //   }
    // });
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        'pushnotification',
        'pushnotificationchannel',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        visibility: NotificationVisibility.public,
        sound: RawResourceAndroidNotificationSound('notification'),
        icon: '@mipmap/ic_launcher',
      ));

      await notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['senderId'],
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
