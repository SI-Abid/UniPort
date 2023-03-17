import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';

import '../services/helper.dart';
import '../services/providers.dart';
import 'message.dart';

class User extends ChangeNotifier {
  // common data
  String? usertype;
  bool? approved;
  String? email;
  String uid;
  String? firstName;
  String? lastName;
  String? contact;
  String? department;
  String? photoUrl;
  // if teacher
  String? teacherId;
  String? initials;
  String? designation;
  bool? isHod;
  // if student
  String? studentId;
  String? section;
  String? batch;
  User({
    this.uid = '',
    this.usertype = 'student',
    this.approved = false,
    this.email,
    this.firstName,
    this.lastName,
    this.contact,
    this.department,
    this.teacherId,
    this.initials,
    this.designation,
    this.studentId,
    this.section,
    this.batch,
    this.photoUrl,
    this.isHod = false, // head of department (hod)
  });

  void copyWith(User user) {
    usertype = user.usertype;
    approved = user.approved;
    email = user.email;
    uid = user.uid;
    firstName = user.firstName;
    lastName = user.lastName;
    contact = user.contact;
    department = user.department;
    teacherId = user.teacherId;
    initials = user.initials;
    designation = user.designation;
    studentId = user.studentId;
    section = user.section;
    batch = user.batch;
    photoUrl = user.photoUrl;
    isHod = user.isHod;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> object = {
      'usertype': usertype,
      'approved': approved,
      'email': email,
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'contact': contact,
      'department': department,
      'photoUrl': photoUrl,
    };
    if (usertype == 'student') {
      object['studentId'] = studentId;
      object['section'] = section;
      object['batch'] = batch;
    }
    if (usertype == 'teacher') {
      object['teacherId'] = teacherId;
      object['initials'] = initials;
      object['designation'] = designation;
      object['isHod'] = isHod;
    }
    return object;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      usertype: json['usertype'],
      approved: json['approved'],
      email: json['email'],
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      contact: json['contact'],
      department: json['department'],
      teacherId: json['teacherId'],
      initials: json['initials'],
      designation: json['designation'],
      studentId: json['studentId'],
      section: json['section'],
      batch: json['batch'],
      photoUrl: json['photoUrl'],
      isHod: json['isHod'],
    );
  }

  String get name => '${firstName ?? 'A'} ${lastName ?? '?'}';

  @override
  String toString() {
    return 'User{usertype: $usertype, approved: $approved, email: $email, uid: $uid, firstName: $firstName, lastName: $lastName, contact: $contact, department: $department, teacherId: $teacherId, initials: $initials, designation: $designation, studentId: $studentId, section: $section, batch: $batch, photoUrl: $photoUrl, isHod: $isHod}';
  }

  Future<void> signOut() async {
    int lastSeen = DateTime.now().millisecondsSinceEpoch;
    final docRef =
        FirebaseFirestore.instance.collection('onlineStatus').doc(uid);
    docRef.get().then((value) {
      if (value.data()?['online'] != false) {
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(docRef, {
            'online': false,
            'lastSeen': lastSeen,
          });
        }).then((value) => FirebaseAuth.instance.signOut());
      }
    });
    await prefs.remove('user');
    await google.disconnect();
    // await google.signOut();
    copyWith(User());
    notifyListeners();
  }

  Future<bool> load() async {
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
            copyWith(User.fromJson(value.data()!));
            prefs.setString('user', jsonEncode(toJson()));
          }
        });
      } catch (e) {
        return false;
      }
    } else {
      copyWith(User.fromJson(jsonDecode(prefs.getString('user')!)));
    }
    if (department != null) {
      updateOnlineStatus(true);
      return true;
    }
    return false;
  }

  Future<bool> save() async =>
      await prefs.setString('user', jsonEncode(toJson()));

  Future<bool> create(String password) async {
    try {
      // final creds = await FirebaseFirestore.instance.collection('logindata').doc(loggedInUser.email).get();
      final creds = await google.currentUser!.authentication;
      // print(creds);
      await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
              accessToken: creds.accessToken, idToken: creds.idToken));
      // print('firebase $creden');
      await FirebaseAuth.instance.currentUser!.updatePassword(password);
      await signOut(); // sign out will save the user data to firebase
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void sendMessage(User sender, Message message) {
    String chatId = getChatId(sender.uid, uid);
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [
        sender.toJson(),
        toJson(),
      ],
      'messages': [
        message.toJson(),
      ],
    }, SetOptions(merge: true));
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await load();
    } catch (e) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<String> loginWithGoogle() async {
    try {
      final signIn = await google.signIn();
      if (signIn == null) {
        return 'cancelled';
      }
      final creds = await signIn.authentication;
      final creden = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: creds.accessToken,
          idToken: creds.idToken,
        ),
      );
      email = creden.user!.email;
      // Commented out for the purpose of testing
      // if (!loggedInUser.email!.endsWith('@lus.ac.bd')) {
      //   loggedInUser = User();
      //   await prefs.remove('user').then((value) => google.signOut());
      //   await FirebaseAuth.instance.currentUser!.delete();
      //   return 'invalid email';
      // }
      // add user to firestore
      await FirebaseFirestore.instance
          .collection('logindata')
          .doc(creden.user!.email)
          .set({
        'idToken': creds.idToken,
        'accessToken': creds.accessToken,
      });
      uid = FirebaseAuth.instance.currentUser!.uid;
      photoUrl = FirebaseAuth.instance.currentUser!.photoURL;
      notifyListeners();
      return await load() ? 'success' : 'new user';
    } catch (e) {
      return 'error';
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
          email: user!.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePhoto(String url) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': url,
      });
      photoUrl = url;
      return save();
    } catch (e) {
      return false;
    }
  }

  void updateOnlineStatus(bool online) {
    if (uid.isEmpty) {
      return;
    }
    int lastSeen = DateTime.now().millisecondsSinceEpoch;
    final docRef =
        FirebaseFirestore.instance.collection('onlineStatus').doc(uid);
    docRef.get().then((value) {
      if (value.data()?['online'] != online) {
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.set(docRef, {
            'online': online,
            'lastSeen': lastSeen,
          });
        });
      }
    });
  }

  bool get isLoggedIn => uid != "";
}
