import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:uniport/version_1/models/user.dart';

class Message {
  String chatId; // id of the chat the message belongs to
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
    this.chatId = '',
  });
  final key = Key.fromLength(32);
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
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
      chatId: json['chatId'],
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

  void delete(String chatId, bool isLast, Message? previousMessage) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(createdAt.toString())
        .delete();
    if (isLast) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .update({'lastMessage': previousMessage!.toJson()});
    }
  }

  void update(String newMsg, bool lastMessage) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(createdAt.toString())
        .update({'content': encrypt(newMsg)});
    if (lastMessage) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .update({'lastMessage.content': encrypt(newMsg)});
    }
  }

  @override
  String toString() {
    return 'Message(chatId: $chatId, content: $content, sender: $sender, type: $type, createdAt: $createdAt, readAt: $readAt)';
  }
}

enum MessageType {
  text,
  image,
}

class GroupMessage {
  final Message message;
  final UserModel sender;

  GroupMessage({
    required this.message,
    required this.sender,
  });
}
