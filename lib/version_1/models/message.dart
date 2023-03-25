import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';

class Message {
  final String content; // message content
  final String sender; // uid of the sender
  final MessageType type; // type of the message
  final int createdAt; // timestamp of the message
  final int? readAt; // timestamp of the message
  Message({
    required this.content,
    required this.sender,
    required this.createdAt,
    this.type = MessageType.text,
    this.readAt,
  });
  final key = Key.fromLength(32);
  Map<String, dynamic> toJson() {
    return {
      'content': encrypt(content),
      'sender': sender,
      'createdAt': createdAt,
      'type': type.index,
      'readAt': readAt,
    };
  }

  static final _key = Key.fromLength(32);
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String input) {
    // final sanitizedInput = input.replaceAll(' ', '');
    final encrypted = _encrypter.encrypt(input, iv: _iv);
    return encrypted.base64;
  }

  static String decrypt(String encryptedString) {
    final encrypted = Encrypted.fromBase64(encryptedString);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return decrypted;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: decrypt(json['content']),
      sender: json['sender'],
      createdAt: json['createdAt'],
      type: MessageType.values[json['type']],
      readAt: json['readAt'],
    );
  }

  void markAsRead(String chatId) {
    final readTime = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseFirestore.instance.collection('chats').doc(chatId);
    ref
        .collection('messages')
        .doc(createdAt.toString())
        .update({'readAt': readTime});
    ref.update({'lastMessage.readAt': readTime});
  }

  void delete(String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(createdAt.toString())
        .delete();
  }

  void update(String newMsg, String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(createdAt.toString())
        .update({'content': newMsg});
  }
}

enum MessageType {
  text,
  image,
}
