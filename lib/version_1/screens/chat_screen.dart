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
    ref.read(userProvider.notifier).getAllUsers().then((value) {
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
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Avatar(user: user, size: 22),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            isSearching ? _getSearchList() : _getChatList(allUsers, user),
          ],
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
    );
  }

  Expanded _getChatList(List<UserModel> users, UserModel user) {
    final chatListStream =
        ref.watch(chatControllerProvider).lastMessageStream();
    return Expanded(
      child: StreamBuilder(
          stream: chatListStream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if(data==null){
              return const LoadingScreen();
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) => StreamBuilder(
                stream: data[index],
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final lastMessage = snapshot.data as LastMessage;
                    final sender = lastMessage.sender;
                    final message = lastMessage.message;
                    return SizedBox(
                      height: 60,
                      child: ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, MessageScreen.routeName,
                              arguments: sender);
                        },
                        leading: Avatar(user: sender),
                        title: Text(
                          sender.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          message.content,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              )
            );
          }),
    );
  }

  Expanded _getSearchList() {
    return Expanded(
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
