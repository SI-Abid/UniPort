import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/router.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import 'version_1/providers/providers.dart';
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
    final status = ref.watch(userProvider.select((value) => value.status));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniPort',
      themeMode: ThemeMode.light,
      onGenerateRoute: generateRoute,
      initialRoute: WelcomePageScreen.routeName,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: status == Status.loggedIn
          ? const HomeScreen()
          : status == Status.newUser
              ? const PersonalInfoScreen()
              : const LoginScreen(),
    );
  }
}
