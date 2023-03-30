import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:uniport/version_1/providers/providers.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.debug = false});
  final bool debug;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late final ChatProvider chatProvider;
  late final AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    authProvider = context.read<AuthProvider>();
    // * LISTEN FOR USER TOKEN REFRESH
    LocalNotification.listenForTokenRefresh();

    // * LISTEN FOR NOTIFICATION TAP
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LocalNotification.handleMessageTap(context, message);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  void registerNotification() {
    firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null && token != chatProvider.user.pushToken) {
        chatProvider.updatePushToken(token);
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'com.example.uniport',
      'Uniport',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    print(message.notification);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data['chatId'],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatProvider.updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      chatProvider.updateOnlineStatus(true);
    } else {
      chatProvider.updateOnlineStatus(false);
    }
    debugPrint('HomeScreen: $state');
  }

  @override
  Widget build(BuildContext context) {
    final double ratio = MediaQuery.of(context).size.aspectRatio;
    debugPrint('HomeScreen: $ratio');
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'UNIPORT'),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          const NotificationButton(),
          GestureDetector(
            onTap: () {
              authProvider.handleSignOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false);
            },
            child: Card(
              elevation: 2,
              shape: const CircleBorder(),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.teal.shade800,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 10,
            spacing: 10,
            children: [
              // *NOTE: for all users
              const CustomCard(
                  iconPath: 'assets/icon/chat_any.svg',
                  title: 'CHAT',
                  subtitle: 'ONE-ONE',
                  actionName: 'MESSAGE',
                  routeName: '/chat'),
              // *NOTE: for students
              if (chatProvider.user.usertype == 'student' || widget.debug) ...[
                const CustomCard(
                    iconPath: 'assets/icon/anonymous.svg',
                    title: 'CHAT',
                    subtitle: 'ANONYMOUS',
                    actionName: 'REPORT',
                    routeName: '/studentReport'),
                const CustomCard(
                    iconPath: 'assets/icon/group_chat.svg',
                    title: 'GROUP CHAT',
                    subtitle: 'ADVISOR & COURSES',
                    actionName: 'MESSAGE',
                    routeName: '/groupChat'),
              ],
              // *NOTE: for teachers
              if (chatProvider.user.usertype == 'teacher' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/assigned_batch.svg',
                    title: 'ASSIGNED BATCH',
                    subtitle: 'GROUP CHAT',
                    actionName: 'MESSAGE',
                    routeName: '/assignedBatch'),
              if (chatProvider.user.usertype == 'teacher' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/student.svg',
                    title: 'STUDENTS',
                    subtitle: 'PENDING',
                    actionName: 'APPROVE',
                    routeName: '/studentApproval'),
              // * NOTE: for HODs
              if (chatProvider.user.isHod == true || widget.debug) ...[
                const CustomCard(
                    iconPath: 'assets/icon/teacher.svg',
                    title: 'TEACHERS',
                    subtitle: 'PENDING',
                    actionName: 'APPROVE',
                    routeName: '/teacherApproval'),
                const CustomCard(
                  iconPath: 'assets/icon/batch_advisor.svg',
                  title: 'ADVISOR',
                  subtitle: 'BATCH',
                  actionName: 'ASSIGN',
                  routeName: '/assignAdvisor',
                ),
                const CustomCard(
                    iconPath: 'assets/icon/anonymous.svg',
                    title: 'REPORTS',
                    subtitle: 'ANONYMOUS',
                    actionName: 'VIEW',
                    routeName: '/reportView'),
              ]
            ],
          ),
        ),
      ),
      backgroundColor:
          widget.debug ? Colors.deepPurple.shade100 : const Color(0xfff5f5f5),
    );
  }
}
