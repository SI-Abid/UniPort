import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

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
    setupInteractedMessage();
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

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      final senderId = message.data['sender'];
      FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get()
          .then((value) {
        final sender = User.fromJson(value.data()!);
        Navigator.of(context).pushReplacementNamed('/message', arguments: sender);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.resumed){
      loggedInUser.updateOnlineStatus(true);
      loggedInUser.updatePushToken();
    }else{
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
