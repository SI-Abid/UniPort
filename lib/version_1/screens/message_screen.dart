import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.messageSender});
  final User messageSender;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String chatId;
  late List<Message> messages;
  late User messageSender;
  int count = 0;
  bool profileViewed = false;
  // late User loggedInUser;
  @override
  void initState() {
    super.initState();
    messageSender = widget.messageSender;
    chatId = getChatId(loggedInUser.uid, messageSender.uid);
    messages = [];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(loggedInUser);
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: true,
        leadingWidth: 24,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(messageSender: messageSender),
            Text(
              messageSender.name,
              style: GoogleFonts.sen(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.01,
            ),
          ],
        ),
        // centerTitle: true,
        // actionsIconTheme: IconThemeData(color: Colors.teal.shade800),
        iconTheme: IconThemeData(color: Colors.teal[800]),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.teal.shade800,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
                    .copyWith(topRight: const Radius.circular(0))),
            padding: const EdgeInsets.all(10),
            elevation: 10,
            color: Colors.grey.shade200,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('View Profile'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Delete Chat'),
              ),
            ],
            onSelected: (value) {
              if (value == 1) {
                setState(() {
                  profileViewed = true;
                });
              } else if (value == 2) {
                FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatId)
                    .delete();
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const LoadingScreen();
                      }
                      final Map<String, dynamic> data =
                          snapshot.data!.data() ?? {};
                      // if data is epmty
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet',
                            style: GoogleFonts.sen(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                      messages = (data['messages'] as List<dynamic>)
                          .map((e) => Message.fromJson(e))
                          .toList();
                      if (messages.length > count) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        });
                        count = messages.length;
                      }
                      return ListView.builder(
                        // dragStartBehavior: DragStartBehavior.down,
                        // reverse: true,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.sender == loggedInUser.uid;
                          return MessageTile(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      );
                    },
                  ),
                  if (profileViewed) ProfileCard(messageSender: messageSender)
                ],
              ),
            ),
            Container(
              color: const Color(0xfff5f5f5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      autofillHints: const [AutofillHints.name],
                      enableSuggestions: true,
                      textInputAction: kIsWeb
                          ? TextInputAction.send
                          : TextInputAction.newline,
                      onEditingComplete: _sendMessage,
                      maxLines: 4,
                      minLines: 1,
                      onTapOutside: (event) {
                        setState(() {
                          profileViewed = false;
                        });
                        FocusScope.of(context).unfocus();
                      },
                      // if keyboard is open, scroll to bottom
                      onTap: () {
                        setState(() {
                          profileViewed = false;
                        });
                        if (messages.isNotEmpty) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          });
                        }
                      },
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type something...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: 50,
                    // padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade800,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    String text = _controller.text.trim();
    _controller.clear();
    if (text.isEmpty) {
      return;
    }
    final message = Message(
      sender: loggedInUser.uid,
      message: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [loggedInUser.toJson(), messageSender.toJson()],
      'messages': FieldValue.arrayUnion([message.toJson()])
    }, SetOptions(merge: true)).then((value) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }
}
