import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uniport/version_1/services/helper.dart';
import 'package:uniport/version_1/services/providers.dart';

import '../models/user.dart';

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

  static Future<void> initialize() async {
    await requestNotificationPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static void handleMessageTap(BuildContext context, RemoteMessage message) {
    if (message.notification != null) {
      String userId = message.data['sender']!;
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((value) {
        UserModel user = UserModel.fromJson(value.data()!);
        if (context.mounted) {
          return;
        }
        Navigator.of(context).pushNamed('/message', arguments: user);
      });
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'chat',
        'chatchannel',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
      );
      final largeIconBytes =
          await getLargeIconBytes(message.data['senderIcon']);
      final largeIcon = largeIconBytes != null
          ? DrawableResourceAndroidBitmap(
              largeIconBytes.buffer.asUint8List().toString())
          : null;
      NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: channel.importance,
        priority: Priority.high,
        ticker: 'ticker',
        visibility: NotificationVisibility.public,
        sound: channel.sound,
        icon: '@mipmap/ic_launcher',
        largeIcon: largeIcon ??
            const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        category: AndroidNotificationCategory.message,
        groupKey: message.data['sender'],
      ));

      await notificationsPlugin.show(
        id,
        message.notification?.title ?? 'New Message',
        message.notification?.body ?? 'You have a new message',
        notificationDetails,
        payload: message.data['sender'],
      );
    } on Exception catch (e) {
      if (kDebugMode) {
        print('error on show noti: $e');
      }
    }
  }
}
