import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniport/version_1/providers/providers.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final user = chatProvider.user;
    final chats = chatProvider.chatList;
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'CHAT'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Avatar(messageSender: user, size: 22),
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
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(
              height: 6,
            ),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              List users = chats[index]['members'] as List;
              users.removeWhere((element) => element == user.uid);
              String senderId = users.first;
              UserModel sender =
                  chatProvider.getUser(senderId);
              Message lastMessage =
                  Message.fromJson(chats[index]['lastMessage']);
              return ChatTile(
                lastMsg: lastMessage,
                messageSender: sender,
              );
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.teal.shade800,
      //   onPressed: () => userList().then(
      //     (value) async {
      //       // print('button: $value');
      //       await showSearch(
      //         context: context,
      //         delegate: MySearchDelegate(list: value),
      //       );
      //     },
      //   ),
      //   child: const Icon(Icons.textsms_rounded),
      // ),
    );
  }
}
