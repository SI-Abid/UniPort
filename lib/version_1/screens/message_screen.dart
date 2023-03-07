import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.messageSender});
  final MessageSender messageSender;

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
  bool isLoading = true;

  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    widget.messageSender.toUser().then((value) {
      setState(() {
        messageSender = value;
        isLoading = false;
        chatId = getChatId(loggedInUser.uid, messageSender.uid);
      });
    });
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
    final mq = MediaQuery.of(context).size;
    // print(loggedInUser);
    return isLoading
        ? const LoadingScreen()
        : WillPopScope(
            onWillPop: () async {
              if (profileViewed) {
                setState(() {
                  profileViewed = false;
                });
                return false;
              }
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
                return false;
              }
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                leadingWidth: 24,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Avatar(messageSender: messageSender),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messageSender.name,
                          style: GoogleFonts.sen(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(messageSender.uid)
                              .snapshots(),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data;
                              return Text(
                                data['online']
                                    ? 'Online'
                                    : 'Last seen: ${formatTime(data['lastSeen'])}',
                                style: GoogleFonts.sen(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              );
                            } else {
                              return const Text('Loading...');
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                // centerTitle: true,
                // actionsIconTheme: IconThemeData(color: Colors.teal.shade800),
                iconTheme: IconThemeData(color: Colors.teal[800]),
                actions: [
                  PopupMenuButton(
                    onOpened: () {
                      FocusScope.of(context).unfocus();
                    },
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
                color: Colors.green.shade100,
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
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
                                  SchedulerBinding.instance
                                      .addPostFrameCallback((_) {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position.maxScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 100),
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
                                    final isMe =
                                        message.sender == loggedInUser.uid;
                                    return MessageTile(
                                      message: message,
                                      isMe: isMe,
                                    );
                                  },
                                );
                              },
                            ),
                            if (profileViewed)
                              ProfileCard(messageSender: messageSender),
                            if (_isUploading)
                              const Center(child: CircularProgressIndicator())
                          ],
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // emoji button
                                IconButton(
                                  iconSize: 28,
                                  icon: Icon(
                                    Icons.emoji_emotions,
                                    color: Colors.teal.shade800,
                                  ),
                                  onPressed: () {},
                                ),
                                Expanded(
                                  child: TextField(
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    autocorrect: true,
                                    autofillHints: const [AutofillHints.name],
                                    enableSuggestions: true,
                                    textInputAction: TextInputAction.newline,
                                    maxLines: 4,
                                    minLines: 1,
                                    // if keyboard is open, scroll to bottom
                                    onTap: () {
                                      setState(() {
                                        profileViewed = false;
                                      });
                                      if (messages.isNotEmpty) {
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 250),
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
                                // image send button
                                IconButton(
                                  iconSize: 28,
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();

                                    // Picking multiple images
                                    final List<XFile> images = await picker
                                        .pickMultiImage(imageQuality: 70);

                                    // uploading & sending image one by one
                                    for (var i in images) {
                                      debugPrint('Image Path: ${i.path}');
                                      setState(() => _isUploading = true);
                                      await sendChatImage(
                                          widget.messageSender, File(i.path));
                                      setState(() => _isUploading = false);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.image_rounded,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                                IconButton(
                                  iconSize: 28,
                                  onPressed: null,
                                  icon: Icon(Icons.camera_alt_rounded,
                                      color: Colors.teal.shade800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 3),
                          child: MaterialButton(
                            minWidth: 0,
                            padding: const EdgeInsets.only(
                                left: 10, right: 6, top: 10, bottom: 10),
                            shape: const CircleBorder(),
                            onPressed: () {
                              String message = _controller.text.trim();
                              if (message.isNotEmpty) {
                                _sendMessage(message, 0);
                                _controller.clear();
                              }
                            },
                            color: Colors.teal.shade800,
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        SizedBox(width: mq.width * 0.01),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  // send image message
  Future<void> sendChatImage(MessageSender chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = FirebaseStorage.instance.ref().child(
        'images/${getChatId(chatUser.uid, loggedInUser.uid)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      debugPrint('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    _sendMessage(imageUrl, 1);
  }

  // send text message
  void _sendMessage(String content, int type) {
    final message = Message(
      type: type,
      sender: loggedInUser.uid,
      content: content,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [
        loggedInUser.toMessageSender().toJson(),
        messageSender.toMessageSender().toJson()
      ],
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
