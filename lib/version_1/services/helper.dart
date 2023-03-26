import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import '../../firebase_options.dart';
import '../models/chat.dart';
import '../models/user.dart';
import 'providers.dart';

Future<void> initiate() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.instance.setAutoInitEnabled(true);
  FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  LocalNotification.initialize();
  emailAuth = EmailAuth(sessionName: 'UniPort');
  await emailAuth.config(remoteServerConfiguration);
  // await DefaultCacheManager().emptyCache();
  prefs = await SharedPreferences.getInstance();
  google = GoogleSignIn(scopes: <String>[
    'email',
  ]);
  loggedInUser = User();
  await loggedInUser.load();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Got message in Background: ${message.data}');
}

String getChatId(String uid1, String uid2) {
  if (uid1.compareTo(uid2) == 1) {
    return uid1 + uid2;
  } else {
    return uid2 + uid1;
  }
}

Future<List<User>> userList() => FirebaseFirestore.instance
    .collection('users')
    .where('approved', isEqualTo: true)
    .where('uid', isNotEqualTo: loggedInUser.uid)
    .get()
    .then((value) => value.docs.map((e) => User.fromJson(e.data())).toList());

// Stream<List<Chat>> chatStream() => FirebaseFirestore.instance
//     .collection('chats')
//     .where(
//       'users',
//       arrayContains: loggedInUser.toJson(),
//     )
//     .snapshots()
//     .map((event) => event.docs.map((e) => Chat.fromJson(e.data())).toList());

String formatTime(int miliseconds) {
  final time = DateTime.fromMillisecondsSinceEpoch(miliseconds);
  int hour = time.hour;
  int minute = time.minute;
  String ampm = 'AM';
  if (hour > 12) {
    hour -= 12;
    ampm = 'PM';
  }
  hour = hour == 0 ? 12 : hour;
  // if today
  if (time.day == DateTime.now().day) {
    return '$hour:${minute.toString().padLeft(2, '0')} $ampm';
  }
  // if yesterday
  if (time.day == DateTime.now().day - 1) {
    return 'Yesterday';
  }
  return '${time.day}/${time.month}/${time.year}';
}

String? emailValidator(String? email) {
  // Regular expression pattern for matching email // character+.+_+digit
  String pattern = r'^[a-zA-Z0-9._]+@lus.ac.bd$';
  pattern = r'^[a-zA-Z0-9._]+@[a-zA-Z.]+$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(email!)) {
    // If the email is not valid, print an error message
    return 'Please enter a valid email.';
  }
  return null;
}

String? batchValidator(String? batch) {
  // Regular expression pattern for matching 2 digits
  const pattern = r'^[1-9][0-9]$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(batch!)) {
    // If the batch is not valid, print an error message
    return 'Please enter a valid batch.';
  }
  return null;
}

String? sectionValidator(String? section) {
  // Regular expression pattern for matching one alphabet or one alphabet + one alphabet
  const pattern = r'^[a-zA-Z]$|^[a-zA-Z]\+[a-zA-Z]$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(section!)) {
    // If the section is not valid, print an error message
    return 'Please enter a valid section.';
  }
  return null;
}

String? studentIdValidator(String? id) {
  // Regular expression pattern for matching 16 digits
  const pattern = r'^\d{16}$'; // 01822200121012**
  final regex = RegExp(pattern);
  if (!regex.hasMatch(id!)) {
    // If the id is not valid, print an error message
    return 'Please enter a valid ID.';
  }
  return null;
}

String? teacherIdValidator(String? id) {
  // Regular expression pattern for matching 8 digits
  const pattern = r'^\d{6}$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(id!)) {
    // If the id is not valid, print an error message
    return 'Please enter a six digit ID.';
  }
  return null;
}

String? departmentValidator(String? department) {
  return department == null ? 'Please select your department' : null;
}

String? initialsValidator(String? initial) {
  // Regular expression pattern for matching 3 alphabets
  const pattern = r'^[A-Z]{3}$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(initial!)) {
    // If the initial is not valid, print an error message
    return 'Please enter a valid initial.';
  }
  return null;
}

String? designationValidator(String? designation) {
  return designation == null ? 'Please select your designation' : null;
}

String? passwordValidator(String? password) {
  // Regular expression pattern for matching 8 characters
  if (password == null) return null;
  if (password.isEmpty) return 'Please enter a password.';
  const pattern = r'^.{8,}$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(password)) {
    // If the password is not valid, print an error message
    return 'Password must be at least 8 characters.';
  }
  return null;
}

String? phoneValidator(String? phone) {
  // Regular expression pattern for matching 11 digits
  const pattern = r'^01[0-9]{9}$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(phone!)) {
    // If the phone is not valid, print an error message
    return 'Please enter a valid phone number.';
  }
  return null;
}

String? nameValidator(String? name) {
  // Regular expression pattern for matching 3 alphabets
  const pattern = r'^[a-zA-Z]{3,}$';
  final regex = RegExp(pattern);
  if (name!.length < 3) {
    return 'Name must be at least 3 characters.';
  }
  if (!regex.hasMatch(name)) {
    // If the name is not valid, print an error message
    return 'Please enter a valid name.';
  }
  return null;
}
