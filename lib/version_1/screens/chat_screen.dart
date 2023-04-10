import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/models/last_message.dart';
import 'package:uniport/version_1/providers/auth_controller.dart';
import 'package:uniport/version_1/providers/chat_controller.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class ChatScreen extends ConsumerWidget {
  static const routeName = '/chat';
  const ChatScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'CHAT'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ref.watch(userAuthProvider).when(
                  data: (user) => user != null
                      ? Avatar(
                          user: user,
                          size: 22,
                        )
                      : const SizedBox(),
                  loading: () => const SizedBox(),
                  error: (error, stack) => const SizedBox(),
                ),
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
          child: StreamBuilder<List<LastMessage>>(
              stream: ref.watch(chatControllerProvider).lastMessageStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('No chats yet'),
                  );
                }
                List<LastMessage> chats = snapshot.data!;
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 6,
                  ),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    Message msg = chats[index].message;
                    UserModel sender = chats[index].sender;
                    return ChatTile(
                      message: msg,
                      messageSender: sender,
                    );
                  },
                );
              }),
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
