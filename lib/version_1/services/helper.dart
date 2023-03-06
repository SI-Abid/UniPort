import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'providers.dart';

Future<void> initiate() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  emailAuth = EmailAuth(sessionName: 'UniPort');
  await emailAuth.config(remoteServerConfiguration);
  prefs = await SharedPreferences.getInstance();
  google = GoogleSignIn(scopes: <String>[
    'email',
  ]);
  print('user ${prefs.getString('user')}');
  // await prefs.clear();
  loggedInUser = User();
  await loadUser();
  FirebaseAuth.instance.authStateChanges().listen((event) {
    debugPrint('auth state changed $event');
    if (event != null) {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(event.uid);
      docRef.get().then((value) {
        print('value $value');
        if (value.exists) {
          docRef.update({
            'online': true,
            'lastSeen': DateTime.now().millisecondsSinceEpoch
          });
        }
        else{
          docRef.set({
            'online': true,
            'lastSeen': DateTime.now().millisecondsSinceEpoch
          }, SetOptions(merge: true));
        }
      });
    }
    if (event == null && loggedInUser.uid != '') {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(loggedInUser.uid);
      docRef.get().then((value) {
        print('value $value');
        if (value.exists) {
          docRef.update({
            'online': false,
            'lastSeen': DateTime.now().millisecondsSinceEpoch
          });
        }
        else{
          docRef.set({
            'online': false,
            'lastSeen': DateTime.now().millisecondsSinceEpoch
          }, SetOptions(merge: true));
        }
      });
    }
  });
  // FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
  //   for (var element in event.docChanges) {
  //     if (element.type == DocumentChangeType.modified) {
  //       // print('modified ${element.doc.data()}');
  //       if (element.doc.id == loggedInUser.uid) {
  //         loggedInUser = User.fromJson(element.doc.data()!);
  //         saveUser();
  //       }
  //     }
  //   }
  // });
}

Future<bool> createUser(String password) async {
  // save user details to firestore
  // print('creating user ${loggedInUser.toJson()}');
  try {
    // final creds = await FirebaseFirestore.instance.collection('logindata').doc(loggedInUser.email).get();
    final creds = await google.currentUser!.authentication;
    // print(creds);
    await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
            accessToken: creds.accessToken, idToken: creds.idToken));
    // print('firebase $creden');
    await FirebaseAuth.instance.currentUser!.updatePassword(password);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(loggedInUser.uid)
        .update(loggedInUser.toJson());
    await signOut();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

void sendMessage(User sender, Message message) {
  String chatId = getChatId(sender.uid, loggedInUser.uid);
  FirebaseFirestore.instance.collection('chats').doc(chatId).set({
    'users': [
      sender.toJson(),
      loggedInUser.toJson(),
    ],
    'messages': [
      message.toJson(),
    ],
  }, SetOptions(merge: true));
}

String getChatId(String uid1, String uid2) {
  if (uid1.compareTo(uid2) == 1) {
    return uid1 + uid2;
  } else {
    return uid2 + uid1;
  }
}

Future<bool> saveUser() async =>
    await prefs.setString('user', jsonEncode(loggedInUser.toJson()));

Future<bool> loadUser() async {
  String? user = prefs.getString('user');
  debugPrint('loadUser -> $user', wrapWidth: 1024);
  if (user == null) {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if (value.exists) {
          loggedInUser = User.fromJson(value.data()!);
          prefs.setString('user', jsonEncode(loggedInUser.toJson()));
        }
      });
    } catch (e) {
      return false;
    }
  } else {
    loggedInUser = User.fromJson(jsonDecode(prefs.getString('user')!));
  }
  // print('loadUser -> ${loggedInUser.toJson()}');
  return loggedInUser.department != null;
}

Future<List<User>> userList() => FirebaseFirestore.instance
    .collection('users')
    .where('approved', isEqualTo: true)
    .where('uid', isNotEqualTo: loggedInUser.uid)
    .get()
    .then((value) => value.docs.map((e) => User.fromJson(e.data())).toList());

Stream<List<Chat>> allChatStream() => FirebaseFirestore.instance
    .collection('chats')
    .where(
      'users',
      arrayContains: loggedInUser.toJson(),
    )
    .snapshots()
    .map((event) => event.docs.map((e) => Chat.fromJson(e.data())).toList());

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  await Future.delayed(const Duration(seconds: 1));
  loggedInUser = User();
  await prefs.remove('user');
  await google.disconnect();
  await google.signOut();
  return Future.value();
}

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
  // Regular expression pattern for matching three alphabets or 4 alphabets
  const pattern = r'^[A-Z]{2,3}$';
  final regex = RegExp(pattern);
  if (department!.isEmpty) {
    return 'Department name cannot be empty';
  }
  if (!regex.hasMatch(department)) {
    // If the department is not valid, print an error message
    return 'Please enter a valid department.';
  }
  return null;
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
  // Regular expression pattern for matching 3 alphabets
  const pattern = r'^[a-zA-Z\s]+$';
  final regex = RegExp(pattern);
  if (!regex.hasMatch(designation!)) {
    // If the designation is not valid, print an error message
    return 'Please enter a valid designation.';
  }
  return null;
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
