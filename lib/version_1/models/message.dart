import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content; // message content
  final String sender; // uid of the sender
  final int type; // 0 for text, 1 for image
  final int createdAt; // timestamp of the message
  final int? readAt; // timestamp of the message
  Message({
    required this.content,
    required this.sender,
    required this.createdAt,
    this.type = 0,
    this.readAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'createdAt': createdAt,
      'type': type,
      'readAt': readAt,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      sender: json['sender'],
      createdAt: json['createdAt'],
      type: json['type'] ?? 0,
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
}
