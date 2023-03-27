import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import '../models/models.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.debug = false});
  final bool debug;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // * LISTEN FOR USER TOKEN REFRESH
    LocalNotification.listenForTokenRefresh();

    // // * LISTEN FOR NOTIFICATION
    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     print('HomeScreen: $message');
    //   }
    // });

    // // * LISTEN FOR NOTIFICATION WHEN APP IS IN FOREGROUND
    // FirebaseMessaging.onMessage.listen((message) {
    //   print('App in foreground: $message');
    //   if (message.notification != null) {
    //     print('Notification: ${message.notification!.title}');
    //     LocalNotification.showNotification(message);
    //   }
    // });

    // // * LISTEN FOR NOTIFICATION WHEN APP IS IN BACKGROUND
    // FirebaseMessaging.onMessageOpenedApp.listen((message) {
    //   print('App in background: $message');
    //   if (message.notification != null) {
    //     String userId = message.data['senderId']!;
    //     FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(userId)
    //         .get()
    //         .then((value) {
    //       User user = User.fromJson(value.data()!);
    //       Navigator.of(context).pushNamed('/message', arguments: user);
    //     });
    //   }
    // });

    WidgetsBinding.instance.addObserver(this);
    if (loggedInUser.pushToken == null) {
      loggedInUser.updatePushToken();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    loggedInUser.updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      loggedInUser.updateOnlineStatus(true);
      loggedInUser.updatePushToken();
    } else {
      loggedInUser.updateOnlineStatus(false);
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
              Navigator.of(context).pushNamed('/loading');
              loggedInUser.signOut().then((value) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              });
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
              // NOTE: for all users
              const CustomCard(
                  iconPath: 'assets/icon/chat_any.svg',
                  title: 'CHAT',
                  subtitle: 'ONE-ONE',
                  actionName: 'MESSAGE',
                  routeName: '/chat'),
              // NOTE: for students
              if (loggedInUser.usertype == 'student' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/anonymous.svg',
                    title: 'CHAT',
                    subtitle: 'ANONYMOUS',
                    actionName: 'REPORT',
                    routeName: '/studentReport'),
              if (loggedInUser.usertype == 'student' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/group_chat.svg',
                    title: 'GROUP CHAT',
                    subtitle: 'ADVISOR & COURSES',
                    actionName: 'MESSAGE',
                    routeName: '/groupChat'),
              // NOTE: for teachers
              if (loggedInUser.usertype == 'teacher' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/assigned_batch.svg',
                    title: 'ASSIGNED BATCH',
                    subtitle: 'GROUP CHAT',
                    actionName: 'MESSAGE',
                    routeName: '/assignedBatch'),
              if (loggedInUser.usertype == 'teacher' || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/student.svg',
                    title: 'STUDENTS',
                    subtitle: 'PENDING',
                    actionName: 'APPROVE',
                    routeName: '/studentApproval'),
              // NOTE: for HODs
              if (loggedInUser.isHod == true || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/teacher.svg',
                    title: 'TEACHERS',
                    subtitle: 'PENDING',
                    actionName: 'APPROVE',
                    routeName: '/teacherApproval'),
              if (loggedInUser.isHod == true || widget.debug)
                CustomCard(
                  iconPath: 'assets/icon/batch_advisor.svg',
                  title: 'ADVISOR',
                  subtitle: 'BATCH',
                  actionName: 'ASSIGN',
                  routeName: '/assignAdvisor',
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('usertype', isEqualTo: 'teacher')
                                  .where('approved', isEqualTo: true)
                                  .get(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  final List<User> teacherList = [];
                                  for (final doc in snapshot.data!.docs) {
                                    teacherList.add(User.fromJson(
                                        doc.data() as Map<String, dynamic>));
                                  }
                                  // print(teacherList);
                                  return AssignAdvisor(
                                      teacherList: teacherList);
                                }
                                return const LoadingScreen();
                              });
                        },
                      ),
                    );
                  },
                ),
              if (loggedInUser.isHod == true || widget.debug)
                const CustomCard(
                    iconPath: 'assets/icon/anonymous.svg',
                    title: 'REPORTS',
                    subtitle: 'ANONYMOUS',
                    actionName: 'VIEW',
                    routeName: '/reportView'),
            ],
          ),
        ),
      ),
      backgroundColor:
          widget.debug ? Colors.deepPurple.shade100 : const Color(0xfff5f5f5),
    );
  }
}
