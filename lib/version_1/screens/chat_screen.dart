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
    debugPrint(loggedInUser.toString());
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'CHAT'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                .where('members', arrayContains: loggedInUser.uid)
                .orderBy('lastMessage.createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              if (snapshot.data == null) {
                return const SizedBox.shrink();
              }
              final List<Map<String, dynamic>> docs = snapshot.data!.docs
                  .map<Map<String, dynamic>>((e) => e.data())
                  .toList();
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 6,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  List users = docs[index]['members'].toList();
                  users.removeWhere((element) => element == loggedInUser.uid);
                  String senderId = users.first;
                  Message lastMessage = Message.fromJson(
                      docs[index]['lastMessage'] as Map<String, dynamic>);
                  return FutureBuilder(
                      future: getUser(senderId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ChatTile(
                            lastMsg: lastMessage,
                            messageSender: snapshot.data as User,
                          );
                        }
                        return const SizedBox.shrink();
                      });
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

  Future<User> getUser(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return User.fromJson(doc.data()!);
  }
}
