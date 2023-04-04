import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:image/image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniport/version_1/models/models.dart';

class ChatProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  List<UserModel> searchResult = [];
  List<UserModel> _users = [];
  List<Map> chatList = List.empty();
  Map<String, Stream<List<Message>>> chatStream =
      {}; // saving loaded chats as stream to avoid reloading
  int _limit = 20;

  late UserModel _user;
  UserModel get user => _user;
  bool get isTeacher => _user.usertype == 'teacher';
  bool get isStudent => _user.usertype == 'student';
  bool get isHod => _user.isHod == true;
  bool get isApproved => _user.approved == true;
  
  ChatProvider({
    required this.prefs,
    required this.firestore,
    required this.storage,
  });

  void clearData() {
    chatStream.forEach((key, value) {
      value.drain();
    });
    chatList.clear();
    searchResult.clear();
  }

  void initChatProvider() {
    _user = UserModel.fromJson(
      jsonDecode(prefs.getString('user') ?? '{}'),
    );
    // *** GETTING ALL USERS ***
    firestore.collection('users').get().then((value) {
      _users = value.docs
          .map<UserModel>((e) => UserModel.fromJson(e.data()))
          .toList();
      notifyListeners();
    });
    // *** GETTING ALL CHATS ***
    firestore
        .collection('chats')
        .where('members', arrayContains: _user.uid)
        .orderBy('lastMessage.createdAt', descending: true)
        .get()
        .then((value) {
      chatList =
          value.docs.map<Map>((e) => {...e.data(), 'chatId': e.id}).toList();
      notifyListeners();
    });
    initListeners();
  }

  void initListeners() {
    // *** LISTENING TO USER UPDATES ***
    firestore.collection('users').doc(_user.uid).snapshots().listen((event) {
      _user = UserModel.fromJson(event.data() ?? {});
      prefs.setString('user', jsonEncode(_user.toJson()));
      notifyListeners();
    });
    // *** LISTENING TO USERS ***
    firestore.collection('users').snapshots().listen((event) {
      final newUsers = event.docChanges
          .where((element) =>
              element.type == DocumentChangeType.added ||
              element.type == DocumentChangeType.modified)
          .map((e) => UserModel.fromJson(e.doc.data() ?? {}))
          .toList();
      _users.addAll(newUsers);
      final removedUsers = event.docChanges
          .where((element) => element.type == DocumentChangeType.removed)
          .map((e) => UserModel.fromJson(e.doc.data() ?? {}))
          .toList();
      if (removedUsers.isNotEmpty) {
        _users.removeWhere((element) => removedUsers.contains(element));
      }
      notifyListeners();
    });

    // *** LISTENING TO CHATS ***
    firestore
        .collection('chats')
        .where('members', arrayContains: _user.uid)
        .orderBy('lastMessage.createdAt', descending: true)
        .snapshots()
        .listen((event) {
      List<Map> newDocs = event.docChanges
          .where((element) =>
              element.type == DocumentChangeType.added ||
              element.type == DocumentChangeType.modified)
          .map((e) => {...e.doc.data() ?? {}, 'chatId': e.doc.id})
          .toList();
      chatList.addAll(newDocs);
      List<Map> removedDocs = event.docChanges
          .where((element) => element.type == DocumentChangeType.removed)
          .map((e) => {...e.doc.data() ?? {}, 'chatId': e.doc.id})
          .toList();
      if (removedDocs.isNotEmpty) {
        chatList.removeWhere((element) => removedDocs.contains(element));
      }
      notifyListeners();
    });
  }

  buildChatStream(String chatId) {
    if (chatStream.containsKey(chatId)) {
      return chatStream[chatId];
    }
    _limit = 20;
    chatStream[chatId] = firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(_limit)
        .snapshots()
        .map((event) {
      List<Message> docs =
          event.docs.map<Message>((e) => Message.fromJson(e.data())).toList();
      return docs;
    });
    notifyListeners();
    return chatStream[chatId];
  }

  void loadMoreMessages(String chatId) {
    _limit += 20;
    chatStream[chatId] = firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(_limit)
        .snapshots()
        .map((event) {
      List<Message> docs =
          event.docs.map<Message>((e) => Message.fromJson(e.data())).toList();
      return docs;
    });
    notifyListeners();
  }

  Future<void> sendMessage(String chatId, Message message) async {
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());
    await firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.toJson(),
      'members': FieldValue.arrayUnion([message.sender]),
    }, SetOptions(merge: true));
  }

  Future<void> sendImage(String chatId, String filePath) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    // convert image to jpg
    Image? image = await decodeImageFile(filePath);
    if (image != null) {
      Image jpgImage = copyResize(image, width: 600);
      List<int> jpgBytes = encodeJpg(jpgImage);
      File file = File('${filePath.split('.').first}.jpg');
      file.writeAsBytesSync(jpgBytes);
      // upload image to firebase storage
      Reference ref =
          storage.ref().child('images').child(chatId).child('$timestamp.jpg');
      UploadTask uploadTask =
          ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      await uploadTask;
      String url = await ref.getDownloadURL();
      // send image message
      Message message = Message(
        createdAt: timestamp,
        sender: _user.uid,
        type: MessageType.image,
        content: url,
      );
      await sendMessage(chatId, message);
    }
  }

  Future<void> searchUser([String? query]) async {
    // not resetting search result
    if (searchResult.isNotEmpty && query == null) return;
    if (query == null || query.isEmpty) {
      // return 20 users from firestore to show in search screen initially
      searchResult = _users.take(20).toList();
      notifyListeners();
      return;
    }
    // search user by name, if query contains alphabets
    if (RegExp(r'[a-zA-Z] ').hasMatch(query)) {
      searchResult = _users
          .where((element) =>
              element.name.toLowerCase().contains(query.toLowerCase().trim()))
          .toList();
      notifyListeners();
      return;
    }
    // search user by id
    searchResult = _users
        .where((user) =>
            user.studentId!.contains(query) || user.teacherId!.contains(query))
        .toList();
    notifyListeners();
  }

  // *** USER METHODS ***

  Future<bool> changePhoto(String url) async {
    try {
      await firestore.collection('users').doc(_user.uid).update({
        'photoUrl': url,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  void updateOnlineStatus(bool online) {
    if (_user.uid.isEmpty) {
      return;
    }
    int lastSeen = DateTime.now().millisecondsSinceEpoch;
    final docRef = firestore.collection('onlineStatus').doc(_user.uid);
    docRef.get().then((value) {
      if (value.data()?['online'] != online) {
        firestore.runTransaction((transaction) async {
          transaction.set(docRef, {
            'online': online,
            'lastSeen': lastSeen,
          });
        });
      }
    });
  }

  void updatePushToken(String token) {
    if (_user.uid.isEmpty) {
      return;
    }
    final docRef = firestore.collection('users').doc(_user.uid);
    docRef.get().then((value) {
      if (value.data()?['pushToken'] != token) {
        firestore.runTransaction((transaction) async {
          transaction.update(docRef, {
            'pushToken': token,
          });
        });
      }
    });
  }

  UserModel getUser(String uid) {
    return _users.firstWhere((element) => element.uid == uid);
  }
}
