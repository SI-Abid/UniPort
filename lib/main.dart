import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/router.dart';
import 'package:uniport/version_1/screens/no_screen.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import 'version_1/providers/auth_controller.dart';
import 'version_1/services/helper.dart';
import 'version_1/screens/screens.dart';
import 'version_1/models/models.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await LocalNotification.showNotification(message);
}

Future<void> main() async {
  await initiate();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniPort',
      themeMode: ThemeMode.light,
      onGenerateRoute: generateRoute,
      initialRoute: WelcomePageScreen.routeName,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ref.watch(userAuthProvider).when(
            data: (user) {
              if (user != null) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
            loading: () => const LoadingScreen(),
            error: (error, stack) => ErrorScreen(error: error.toString()),
          ),
    );
  }
}
