import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:uniport/version_1/services/notification_service.dart';

import '../services/helper.dart';
import '../services/providers.dart';
import 'message.dart';

class UserModel {
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
  UserModel({
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

  void copyWith(UserModel user) {
    usertype = user.usertype ?? usertype;
    approved = user.approved ?? approved;
    email = user.email ?? email;
    uid = user.uid;
    firstName = user.firstName ?? firstName;
    lastName = user.lastName ?? lastName;
    contact = user.contact ?? contact;
    department = user.department ?? department;
    teacherId = user.teacherId ?? teacherId;
    initials = user.initials ?? initials;
    designation = user.designation ?? designation;
    studentId = user.studentId ?? studentId;
    section = user.section ?? section;
    batch = user.batch ?? batch;
    photoUrl = user.photoUrl ?? photoUrl;
    isHod = user.isHod ?? isHod;
    pushToken = user.pushToken ?? pushToken;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
      pushToken: json['pushToken'],
      isHod: json['isHod'],
    );
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

  String get name => '${firstName ?? 'A'} ${lastName ?? '?'}';

  @override
  String toString() {
    return 'User{usertype: $usertype, approved: $approved, email: $email, uid: $uid, firstName: $firstName, lastName: $lastName, contact: $contact, department: $department, teacherId: $teacherId, initials: $initials, designation: $designation, studentId: $studentId, section: $section, batch: $batch, photoUrl: $photoUrl, isHod: $isHod, pushToken: $pushToken}';
  }
}

  // void sendMessageToUser(User toUser, Message message) {
  //   String chatId = getChatId(toUser.uid, uid);
  //   final docRef = _firestore.collection('chats').doc(chatId);
  //   final msgRef =
  //       docRef.collection('messages').doc(message.createdAt.toString());
  //   // add message to collection and update last message
  //   _firestore.runTransaction((transaction) async {
  //     // docRef doesn't exist, create it
  //     transaction.set(
  //         docRef,
  //         {
  //           'lastMessage': message.toJson(),
  //           'members': FieldValue.arrayUnion([uid, toUser.uid]),
  //         },
  //         SetOptions(merge: true));
  //     transaction.set(msgRef, message.toJson());
  //   }).then((value) => sendPushNotification(toUser, message));
  // }

  // void sendMessageToGroup(String groupId, Message message) {
  //   final docRef = _firestore.collection('advisor groups').doc(groupId);
  //   final msgRef =
  //       docRef.collection('messages').doc(message.createdAt.toString());
  //   _firestore.runTransaction((transaction) async {
  //     transaction
  //         .set(
  //             docRef,
  //             {
  //               'members': FieldValue.arrayUnion([uid]),
  //             },
  //             SetOptions(merge: true))
  //         .set(msgRef, message.toJson())
  //         .update(docRef, {
  //       'lastMessage': message.toJson(),
  //     }).set(
  //             docRef,
  //             {
  //               'lastMessageFrom': name,
  //             },
  //             SetOptions(merge: true));
  //   });
  // }

  // Future<void> sendPushNotification(User toUser, Message message) async {
  //   String? userToken = await _firestore
  //       .collection('users')
  //       .doc(toUser.uid)
  //       .get()
  //       .then((value) => value.data()?['pushToken']);
  //   if (userToken == null) return;
  //   final body = {
  //     'to': userToken,
  //     'notification': {
  //       'title': name,
  //       'body': message.type == MessageType.text ? message.content : 'Image',
  //     },
  //     'data': {
  //       'type': 'chat',
  //       'sender': uid,
  //       'senderIcon': photoUrl,
  //     },
  //     'channel': 'chat',
  //   };
  //   final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  //   // print(dotenv.env['PUSH_KEY']!);
  //   final response = await post(
  //     url,
  //     headers: {
  //       HttpHeaders.contentTypeHeader: 'application/json',
  //       HttpHeaders.authorizationHeader: dotenv.env['PUSH_KEY']!,
  //     },
  //     body: jsonEncode(body),
  //   );
  //   if (kDebugMode) {
  //     print('Push response: ${response.body}');
  //   }
  // }