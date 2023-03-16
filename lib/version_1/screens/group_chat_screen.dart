import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    messages = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'ADVISOR GROUP CHAT'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // more_vert
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    // TODO: group info
                  },
                  child: const Text('Group Info'),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    // TODO: delete group
                  },
                  child: const Text('Delete Group'),
                ),
              ),
            ],
          ),  
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
        ),
        // margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('advisor groups')
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!.data()! as Map<String, dynamic>;
                  messages = data['chats']
                      .map<Message>((e) => Message.fromJson(e))
                      .toList();
                  final chatUsers =
                      data['users'].map<User>((e) => User.fromJson(e)).toList();
                  return Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        bool isMe = messages[index].sender == loggedInUser.uid;
                        User sender = chatUsers.firstWhere(
                            (element) => element.uid == messages[index].sender);
                        return GroupMessageTile(
                            message: messages[index],
                            sender: sender,
                            isMe: isMe);
                      },
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            Container(
              color: const Color(0xfff5f5f5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: 4,
                      minLines: 1,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      // if keyboard is open, scroll to bottom
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
                      onPressed: () {
                        String text = _controller.text.trim();
                        _controller.clear();
                        if (text.isEmpty) {
                          return;
                        }
                        final message = Message(
                          sender: loggedInUser.uid,
                          content: text,
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                        );
                        FirebaseFirestore.instance
                            .collection('advisor groups')
                            .doc(widget.groupId)
                            .update({
                          'users':
                              FieldValue.arrayUnion([loggedInUser.toJson()]),
                          'chats': FieldValue.arrayUnion([message.toJson()])
                        });
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
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
}

class GroupMessageTile extends StatelessWidget {
  const GroupMessageTile(
      {super.key,
      required this.message,
      required this.isMe,
      required this.sender});
  final Message message;
  final bool isMe;
  final User sender;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 0 : 12,
        right: isMe ? 12 : 0,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // sender name and photo
          if (!isMe)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Avatar(messageSender: sender, size: 12),
                ),
                // const SizedBox(width: 4),
                Text(
                  sender.name,
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          Container(
            margin: isMe
                ? const EdgeInsets.only(left: 55)
                : const EdgeInsets.only(right: 55),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 15,
              right: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23),
                    ),
              color: isMe
                  ? Colors.teal.shade800
                  : Colors.teal.shade200.withOpacity(0.5),
            ),
            child: Text(
              message.content,
              style: GoogleFonts.sen(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatTime(message.createdAt),
            style: GoogleFonts.sen(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
