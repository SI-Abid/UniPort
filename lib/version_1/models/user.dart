import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:uniport/version_1/services/notification_service.dart';

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
  String? pushToken;
  // if teacher
  String? teacherId;
  String? initials;
  String? designation;
  bool? isHod;
  // if student
  String? studentId;
  String? section;
  String? batch;
  // app data
  String? openedChatId;
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
    this.pushToken,
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
    pushToken = user.pushToken;
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
      'pushToken': pushToken,
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
      pushToken: json['pushToken'],
    );
  }

  String get name => '${firstName ?? 'A'} ${lastName ?? '?'}';

  @override
  String toString() {
    return 'User{usertype: $usertype, approved: $approved, email: $email, uid: $uid, firstName: $firstName, lastName: $lastName, contact: $contact, department: $department, teacherId: $teacherId, initials: $initials, designation: $designation, studentId: $studentId, section: $section, batch: $batch, photoUrl: $photoUrl, isHod: $isHod, pushToken: $pushToken}';
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
        });
      }
    });
    copyWith(User());
    await prefs.remove('user');
    await google.disconnect();
    await FirebaseAuth.instance.signOut();
    // await google.signOut();
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
      notifyListeners();
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(toJson());
      await signOut(); // sign out will save the user data to firebase
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  void sendMessageToUser(User toUser, Message message) {
    String chatId = getChatId(toUser.uid, uid);
    final docRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final msgRef =
        docRef.collection('messages').doc(message.createdAt.toString());
    // add message to collection and update last message
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // docRef doesn't exist, create it
      transaction.set(
          docRef,
          {
            'lastMessage': message.toJson(),
            'members': FieldValue.arrayUnion([uid, toUser.uid]),
          },
          SetOptions(merge: true));
      transaction.set(msgRef, message.toJson());
    }).then((value) => sendPushNotification(toUser, message));
  }

  void sendMessageToGroup(String groupId, Message message) {
    final docRef =
        FirebaseFirestore.instance.collection('advisor groups').doc(groupId);
    final msgRef =
        docRef.collection('messages').doc(message.createdAt.toString());
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction
          .set(
              docRef,
              {
                'members': FieldValue.arrayUnion([uid]),
              },
              SetOptions(merge: true))
          .set(msgRef, message.toJson())
          .update(docRef, {
        'lastMessage': message.toJson(),
      }).set(
              docRef,
              {
                'lastMessageFrom': name,
              },
              SetOptions(merge: true));
    });
  }

  Future<void> sendPushNotification(User toUser, Message message) async {
    String userToken = await FirebaseFirestore.instance
        .collection('users')
        .doc(toUser.uid)
        .get()
        .then((value) => value.data()?['pushToken']);
    final body = {
      'to': userToken,
      'notification': {
        'title': name,
        'body': message.type == MessageType.text ? message.content : 'Image',
      },
      'data': {
        'type': 'chat',
        'sender': uid,
      },
    };
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    // print(dotenv.env['PUSH_KEY']!);
    final response = await post(
      url,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: dotenv.env['PUSH_KEY']!,
      },
      body: jsonEncode(body),
    );
    if (kDebugMode) {
      print('Push response: ${response.body}');
    }
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
      // notifyListeners();
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

  Future<void> updatePushToken([String? token]) async {
    if (uid.isEmpty) {
      return;
    }
    pushToken = token ?? await LocalNotification.getToken();
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'pushToken': pushToken,
    });
  }

  bool get isLoggedIn => uid != "";

  @override
  int get hashCode => uid.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          usertype == other.usertype &&
          approved == other.approved &&
          email == other.email &&
          uid == other.uid &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          contact == other.contact &&
          department == other.department &&
          teacherId == other.teacherId &&
          initials == other.initials &&
          designation == other.designation &&
          studentId == other.studentId &&
          section == other.section &&
          batch == other.batch &&
          photoUrl == other.photoUrl &&
          isHod == other.isHod;
}
