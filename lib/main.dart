import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'version_1/services/helper.dart';
import 'version_1/screens/screens.dart';
import 'version_1/models/models.dart';

Future<void> main() async {
  await initiate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<User>(create: (_) => User())],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UNICHAT',
          themeMode: ThemeMode.light,
          routes: {
            '/welcome': (context) => const WelcomePageScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/loading': (context) => const LoadingScreen(),
            '/chat': (context) => const ChatScreen(),
            '/message': (context) => MessageScreen(
                messageSender:
                    ModalRoute.of(context)!.settings.arguments as User),
            '/reportView': (context) => const ReportViewScreen(),
            '/studentReport': (context) => StudentReportScreen(),
            '/studentApproval': (context) => const StudentApproval(),
            '/teacherApproval': (context) => const TeacherApproval(),
            '/groupChat': (context) => const GroupChat(),
            '/assignedBatch': (context) => const AssignedBatchScreen(),
          },
          initialRoute: '/welcome',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Consumer<User>(
            builder: (context, User user, child) {
              final userProvider = context.read<User>();
              if (userProvider.isLoggedIn) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          )
          // StreamBuilder(
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
