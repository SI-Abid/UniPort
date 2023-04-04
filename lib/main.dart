import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import 'version_1/services/helper.dart';
import 'version_1/screens/screens.dart';
import 'version_1/models/models.dart';
import 'version_1/providers/providers.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotification.showNotification(message);
}

Future<void> main() async {
  await initiate();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.prefs});
  final SharedPreferences prefs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final EmailAuth _emailAuth = EmailAuth(sessionName: 'UniPort');
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthProvider(
                  emailAuth: _emailAuth,
                  firebaseAuth: _auth,
                  firestore: _firestore,
                  googleSignIn: _googleSignIn,
                  prefs: prefs,
                )),
        ChangeNotifierProvider(
            create: (_) => ChatProvider(
                  prefs: prefs,
                  firestore: _firestore,
                  storage: _storage,
                )),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UniPort',
          themeMode: ThemeMode.light,
          routes: {
            '/welcome': (context) => const WelcomePageScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/chat': (context) => const ChatScreen(),
            '/message': (context) => MessageScreen(
                messageSender:
                    ModalRoute.of(context)!.settings.arguments as UserModel),
            '/reportView': (context) => const ReportViewScreen(),
            '/studentReport': (context) => StudentReportScreen(),
            '/studentApproval': (context) => const StudentApproval(),
            '/teacherApproval': (context) => const TeacherApproval(),
            '/groupChat': (context) => const GroupChat(),
            '/assignedBatch': (context) => const AssignedBatchScreen(),
            '/assignAdvisor': (context) => const AssignAdvisor(),
          },
          initialRoute: '/welcome',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Consumer(
            builder: (context, ref, child) {
              final bool isLoggedIn =
                  context.watch<AuthProvider>().status == Status.authenticated;
              if (isLoggedIn) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          )
          //     StreamBuilder(
          //   stream: FirebaseAuth.instance.authStateChanges(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.active) {
          //       if (snapshot.hasData) {
          //         return const HomeScreen();
          //       }
          //       return const LoginScreen();
          //     }
          //     return FutureBuilder(
          //       future: Connectivity().checkConnectivity(),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.done) {
          //           if (snapshot.data == ConnectivityResult.none) {
          //             return const LoginScreen();
          //           }
          //         }
          //         return const LoadingScreen();
          //       },
          //     );
          //   },
          // ),
          ),
    );
  }
}
