import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/providers/providers.dart';
import 'package:uniport/version_1/screens/screens.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  static const routeName = '/chat';
  const ChatScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  @override
  void initState() {
    super.initState();
    ref.read(userListProvider).whenData((value) {
      setState(() {
        allUsers = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      filteredUsers = allUsers
                          .where((element) => element.name
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search by name or ID',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            : const AppTitle(title: 'Chats'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          isSearching
              ? IconButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchController.clear();
                    } else {
                      setState(() {
                        isSearching = !isSearching;
                      });
                    }
                  },
                  icon: const Icon(Icons.close))
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: const Icon(Icons.search)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Avatar(user: user),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ChatList(allUsers: allUsers),
          if (isSearching) _getSearchList(),
        ],
      ),
      backgroundColor: const Color(0xfff5f5f5),
    );
  }

  Widget _getSearchList() {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          UserModel user = filteredUsers[index];
          return SizedBox(
            height: 60,
            child: ListTile(
              onTap: () {
                setState(() {
                  searchController.clear();
                  isSearching = false;
                });
                Navigator.pushNamed(context, MessageScreen.routeName,
                    arguments: user);
              },
              leading: Avatar(user: user),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.studentId ?? user.department ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatList extends ConsumerWidget {
  final List<UserModel> allUsers;

  const ChatList({super.key, required this.allUsers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: double.infinity,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: ref.read(userProvider).uid)
            .orderBy('lastMessageAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot> chats = snapshot.data!.docs;
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
              ),
              itemBuilder: (context, index) {
                final stream = chats[index]
                    .reference
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .limit(1)
                    .snapshots();
                return StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final messageMap = snapshot.data!.docs.first.data();
                      final message = Message.fromJson(messageMap);
                      final otherId = message.chatId
                          .replaceAll(ref.read(userProvider).uid, '');
                      final other = allUsers
                          .firstWhere((element) => element.uid == otherId);
                      return ChatTile(message: message, otherUser: other);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
