import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(loggedInUser);
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'CHAT'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Avatar(messageSender: loggedInUser, size: 22),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: SizedBox(
          width: 500,
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where(
                  'users',
                  arrayContains: loggedInUser.toJson(),
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              List<Chat> chatList = [];
              for (var element in snapshot.data!.docs) {
                final data = element.data();
                data['chatId'] = element.id;
                chatList.add(Chat.fromJson(data));
              }
              chatList.sort((a, b) {
                final aTime = a.lastMessage.createdAt;
                final bTime = b.lastMessage.createdAt;
                return bTime.compareTo(aTime);
              });
              // print(chatDocs.length);
              return ListView.builder(
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  Chat chat = chatList[index];
                  List<User> users = chat.users;
                  users.removeWhere(
                      (element) => element.uid == loggedInUser.uid);
                  User messageSender = users.first;
                  List<Message> messageList = chat.messages;
                  return ChatTile(
                      data: messageList, messageSender: messageSender);
                },
              );
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal.shade800,
        onPressed: () => userList().then(
          (value) async {
            // print('button: $value');
            await showSearch(
              context: context,
              delegate: MySearchDelegate(list: value),
            );
          },
        ),
        child: const Icon(Icons.textsms_rounded),
      ),
    );
  }
}
