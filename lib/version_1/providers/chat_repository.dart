import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart';
import 'package:uniport/version_1/models/models.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

class ChatRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRepository({
    required this.auth,
    required this.firestore,
    required this.storage,
  });

  // *** CHAT STREAM ***
  Stream<List<Message>> getChatStream(String recieverId) {
    String chatId = _getChatId(auth.currentUser!.uid, recieverId);
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) {
      List<Message> docs =
          event.docs.map<Message>((e) => Message.fromJson(e.data())).toList();
      return docs;
    });
  }

  String _getChatId(String senderId, String recieverId) {
    if (senderId.hashCode <= recieverId.hashCode) {
      return '$senderId-$recieverId';
    }
    return '$recieverId-$senderId';
  }

  Future<void> _sendMessage(String chatId, Message message) async {
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());
    await firestore.collection('chats').doc(chatId).set({
      // 'lastMessage': message.toJson(),
      'members': FieldValue.arrayUnion([message.sender]),
    }, SetOptions(merge: true));
  }

  // *** SENDING TEXT MESSAGE ***
  Future<void> sendText(
      UserModel sender, String recieverId, String text) async {
    String chatId = _getChatId(sender.uid, recieverId);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Message message = Message(
      sender: sender.uid,
      content: text,
      createdAt: timestamp,
      type: MessageType.text,
    );
    _sendMessage(chatId, message);
  }

  // *** SENDING IMAGE ***
  Future<void> sendImage(
      UserModel sender, String recieverId, String filePath) async {
    String chatId = _getChatId(sender.uid, recieverId);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    // convert image to jpg
    Image? image = await decodeImageFile(filePath);
    if (image != null) {
      String url = await _uploadChatImage(image, chatId, filePath, timestamp);
      Message message = Message(
        sender: sender.uid,
        content: url,
        createdAt: timestamp,
        type: MessageType.image,
      );
      _sendMessage(chatId, message);
    }
  }

  // *** DELETE MESSAGE ***
  Future<void> deleteMessage(
      {required String chatId, required Message message}) async {
    await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.createdAt.toString())
        .delete();
    // if message is image, delete image from storage
    if (message.type == MessageType.image) {
      Reference ref = storage.refFromURL(message.content);
      await ref.delete();
    }
  }

  // *** DELETE CHAT ***
  Future<void> deleteChat(
      {required String chatId, required String collection}) async {
    await firestore
        .collection(collection)
        .doc(chatId)
        .collection('messages')
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
    await firestore.collection(collection).doc(chatId).delete();
    // delete chat images from storage
    await storage.ref().child('$collection/$chatId').listAll().then((value) {
      for (var ref in value.items) {
        ref.delete();
      }
    });
  }

  // *** LAST MESSAGE STREAM ***
  Stream<List<LastMessage>> getLastMessageStream() {
    // get the last message from messages subcollection of each chat where user is a member
    // chats -> chatId -> messages -> message
    return firestore
        .collection('chats')
        .where('members', arrayContains: auth.currentUser!.uid)
        .snapshots()
        .map((event) {
      List<LastMessage> lastMessages = [];
      for (var element in event.docs) {
        element.reference
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .limit(1)
            .snapshots()
            .asyncMap((event) async {
          for (var ele in event.docs) {
            final msg = Message.fromJson(ele.data());
            final user = await firestore
                .collection('users')
                .doc(msg.sender)
                .get()
                .then((value) => UserModel.fromJson(value.data()!));
            lastMessages.add(LastMessage(sender: user, message: msg));
          }
        });
      }
      return lastMessages;
    });
  }

  // *** GET GROUP LAST MESSAGE STREAM ***
  Stream<List<GroupLastMessage>> getGroupLastMessageStream(UserModel user) {
    // get the last message from messages subcollection of each chat where user is a member
    // chats -> chatId -> messages -> message
    if (user.usertype == 'teacher') {
      return firestore
          .collection('advisor groups')
          .where('members', arrayContains: auth.currentUser!.uid)
          .snapshots()
          .map((event) {
        List<GroupLastMessage> lastMessages = [];
        for (var element in event.docs) {
          String groupId = element.reference.id;
          String batch = element.data()['batch'];
          List<String> sections = element.data()['sections'];
          element.reference
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .limit(1)
              .snapshots()
              .asyncMap((event) async {
            // get the last message only
            final ele = event.docs.first;
            final msg = Message.fromJson(ele.data());
            msg.chatId = groupId;
            final sender = await firestore
                .collection('users')
                .doc(msg.sender)
                .get()
                .then((value) => UserModel.fromJson(value.data()!));
            lastMessages.add(GroupLastMessage(
                batch: batch,
                sections: sections,
                sender: sender,
                message: msg));
          });
        }
        return lastMessages;
      });
    }
    return firestore
        .collection('advisor groups')
        .where('batch', isEqualTo: user.batch)
        .where('sections', arrayContains: user.section)
        .snapshots()
        .map((event) {
      List<GroupLastMessage> lastMessages = [];
      // from one group only
      final element = event.docs.first;
      String groupId = element.reference.id;
      String batch = element.data()['batch'];
      List<String> sections = element.data()['sections'];
      element.reference
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .asyncMap((event) async {
        // get the last message only
        final ele = event.docs.first;
        final msg = Message.fromJson(ele.data());
        msg.chatId = groupId;
        final sender = await firestore
            .collection('users')
            .doc(msg.sender)
            .get()
            .then((value) => UserModel.fromJson(value.data()!));
        lastMessages.add(GroupLastMessage(
            batch: batch, sections: sections, sender: sender, message: msg));
      });
      return lastMessages;
    });
  }

  // *** GET GROUP CHAT STREAM ***
  Stream<List<GroupMessage>> getGroupChatStream(String docId) {
    return firestore
        .collection('advisor groups')
        .doc(docId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((event) async {
      List<GroupMessage> docs = [];
      for (var element in event.docs) {
        final msg = Message.fromJson(element.data());
        final sender = await firestore
            .collection('users')
            .doc(msg.sender)
            .get()
            .then((value) => UserModel.fromJson(value.data()!));
        docs.add(GroupMessage(sender: sender, message: msg));
      }
      return docs;
    });
  }

  Future<String> _uploadChatImage(
      Image image, String chatId, String filePath, int timestamp) async {
    Image jpgImage = copyResize(image, width: 600);
    List<int> jpgBytes = encodeJpg(jpgImage);
    File file = File('${filePath.split('.').first}.jpg');
    file.writeAsBytesSync(jpgBytes);
    // upload image to firebase storage
    Reference ref =
        storage.ref().child(chatId).child('images').child('$timestamp.jpg');
    UploadTask uploadTask =
        ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    await uploadTask;
    return await ref.getDownloadURL();
  }

  Future<void> _sendGroupMessage(String groupId, Message message) async {
    await firestore
        .collection('advisor groups')
        .doc(groupId)
        .collection('messages')
        .add(message.toJson());
  }

  // *** SEND GROUP MESSAGE ***
  Future<void> sendGroupText(
      UserModel sender, String groupId, String text) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Message message = Message(
      sender: sender.uid,
      content: text,
      createdAt: timestamp,
      type: MessageType.text,
    );
    _sendGroupMessage(groupId, message);
  }

  // *** SEND GROUP IMAGE ***
  Future<void> sendGroupImage(
      UserModel sender, String groupId, String filePath) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    // convert image to jpg
    Image? image = await decodeImageFile(filePath);
    if (image != null) {
      String url = await _uploadChatImage(image, groupId, filePath, timestamp);
      Message message = Message(
        sender: sender.uid,
        content: url,
        createdAt: timestamp,
        type: MessageType.image,
      );
      _sendGroupMessage(groupId, message);
    }
  }

  // *** GET BATCH LIST ***
  Future<List<BatchModel>> getBatchList() async {
    List<BatchModel> batches = [];
    await firestore.collection('batchInfo').get().then((value) {
      for (var element in value.docs) {
        batches.add(BatchModel.fromJson(element.data()));
      }
    });
    return batches;
  }

  // *** GET APPROVED TEACHERS LIST ***
  Future<List<UserModel>> getApprovedTeachersList() async {
    List<UserModel> teachers = [];
    await firestore
        .collection('users')
        .where('usertype', isEqualTo: 'teacher')
        .where('approved', isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        teachers.add(UserModel.fromJson(element.data()));
      }
    });
    return teachers;
  }

  // *** MARK AS READ ***
  Future<void> markAsRead(Message message) async {
    String chatCollection = message.chatId.length < 50 ? 'advisor groups' : 'chats';
    await firestore
        .collection(chatCollection)
        .doc(message.chatId)
        .collection('messages')
        .doc(message.createdAt.toString())
        .update({'readAt': DateTime.now().millisecondsSinceEpoch});
  }
}
