//  chats{
//     chatId{ // chatId = user1.uid + user2.uid
//       users: [
//         user1{
//           email: email
//           uid: uid
//           name: name
//           usertype: usertype
//         },
//         user2{
//           email: email
//           uid: uid
//           name: name
//           usertype: usertype
//         },
//       ],
//       messages: [
//         {
//           message: 'hello',
//           sender: 'user1',
//           timestamp: 1234567890
//         },
//         {
//           message: 'hello',
//           sender: 'user2',
//           timestamp: 1234567890
//         },
//       ]
//  }

import 'models.dart';

class Chat {
  final String chatId;
  final List<MessageSender> users;
  final List<Message> messages;
  Chat({
    required this.chatId,
    required this.users,
    required this.messages,
  });
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'users': users.map((e) => e.toJson()).toList(),
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      users: (json['users'] as List)
          .map((e) => MessageSender.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  get lastMessage => messages.last;
}
