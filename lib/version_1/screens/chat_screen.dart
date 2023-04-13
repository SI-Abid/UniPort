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
            ? TextField(
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
              )
            : const Text(
                'Chats',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          IconButton(
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
            isSearching
                ? SearchUserList(
                    ref: ref,
                    filteredList: filteredUsers,
                  )
                : ChatList(ref: ref),
          ],
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
    );
  }
}

class SearchUserList extends StatelessWidget {
  const SearchUserList({
    super.key,
    required this.ref,
    required this.filteredList,
  });

  final WidgetRef ref;
  final List<UserModel> filteredList;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 500,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(
          height: 6,
        ),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          UserModel user = filteredList[index];
          return ListTile(
            onTap: () {
              Navigator.pushNamed(context, MessageScreen.routeName,
                  arguments: user);
            },
            leading: Avatar(user: user, size: 40),
            title: Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              user.studentId ?? user.teacherId ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 500,
      child: StreamBuilder(
          stream: ref.watch(chatControllerProvider).groupLastMessageStream(),
          builder: (context, AsyncSnapshot<List<LastMessage>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 6,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  LastMessage lastMessage = snapshot.data![index];
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, MessageScreen.routeName,
                          arguments: lastMessage.message.chatId);
                    },
                    leading: Avatar(user: lastMessage.sender, size: 40),
                    title: Text(
                      lastMessage.sender.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage.message.content,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
