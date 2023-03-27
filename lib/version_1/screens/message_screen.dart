import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';

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
  late List<QueryDocumentSnapshot> messages;
  late User messageSender;
  int count = 0;
  bool profileViewed = false;

  bool _showEmoji = false;
  int _limit = 20;
  final int _limitIncrement = 20;

  @override
  void initState() {
    super.initState();
    messageSender = widget.messageSender;
    loggedInUser.openedChatId = messageSender.uid;
    chatId = getChatId(loggedInUser.uid, messageSender.uid);
    messages = [];
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        _limit <= messages.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    loggedInUser.openedChatId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    // print(loggedInUser);
    return WillPopScope(
      onWillPop: () async {
        if (profileViewed) {
          setState(() {
            profileViewed = false;
          });
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
                        .collection('onlineStatus')
                        .doc(messageSender.uid)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data;
                        return data['online']
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Online',
                                    style: GoogleFonts.sen(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Last seen: ${formatTime(data['lastSeen'])}',
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
                  if (kDebugMode) {
                    print('storage path: images/$chatId');
                  }
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .get()
                      .then((value) => value.docs.forEach((element) {
                            element.reference.delete();
                          }))
                      .then((value) => FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .delete())
                      .then((value) => FirebaseStorage.instance
                          .ref()
                          .child('images/$chatId')
                          .delete())
                      .then((value) => Navigator.pop(context));
                  // FirebaseStorage.instance
                  //     .ref()
                  //     .child('images/$chatId')
                  //     .list()
                  //     .then((value) {
                  //   for (var element in value.items) {
                  //     if (kDebugMode) {
                  //       print(element.name);
                  //     }
                  //     // element.delete();
                  //   }
                  // });
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
                    setState(() {
                      _showEmoji = false;
                      profileViewed = false;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId)
                            .collection('messages')
                            .orderBy('createdAt', descending: true)
                            .limit(_limit)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const SizedBox.shrink();
                          }
                          messages = snapshot.data!.docs;
                          // if data is epmty
                          if (messages.isEmpty) {
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
                          final messageList = messages
                              .map((e) => Message.fromJson(
                                  e.data() as Map<String, dynamic>))
                              .toList();
                          return ListView.builder(
                            reverse: true, // * MESSAGE LIST IS REVERSED
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messageList[index];
                              final isMe = message.sender == loggedInUser.uid;
                              Message? nextMssg =
                                  index != 0 ? messageList[index - 1] : null;
                              Message? prevMssg = index != messages.length - 1
                                  ? messageList[index + 1]
                                  : null;
                              return MessageTile(
                                chatId: chatId,
                                message: message,
                                isMe: isMe,
                                nextMsg: nextMssg,
                                prevMsg: prevMssg,
                                isLast: index == 0,
                              );
                            },
                          );
                        },
                      ),
                      if (profileViewed)
                        ProfileCard(messageSender: messageSender),
                    ],
                  ),
                ),
              ),
              chatInput(mq, context),
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    onBackspacePressed: () => setState(() {
                      if (_controller.text.isNotEmpty) {
                        _controller.text = _controller.text.characters
                            .toList()
                            .map((e) => e.toString())
                            .toList()
                            .sublist(0, _controller.text.characters.length)
                            .join();
                      }
                    }),
                    textEditingController: _controller,
                    config: Config(
                      emojiTextStyle: GoogleFonts.sen(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      checkPlatformCompatibility: true,
                      backspaceColor: Colors.blueGrey.shade900,
                      enableSkinTones: true,
                      indicatorColor: Colors.teal.shade400,
                      iconColorSelected: Colors.teal.shade400,
                      buttonMode: ButtonMode.MATERIAL,
                      iconColor: Colors.teal.shade800,
                      bgColor: Colors.green.shade200,
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Padding chatInput(Size mq, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.01),
      child: Row(
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
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      textInputAction: TextInputAction.newline,
                      maxLines: 4,
                      minLines: 1,
                      // if keyboard is open, scroll to bottom
                      onTap: () {
                        setState(() {
                          profileViewed = false;
                          _showEmoji = false;
                        });
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
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
                    padding: const EdgeInsets.all(0),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);

                      // uploading & sending image one by one
                      for (var i in images) {
                        debugPrint('Image Path: ${i.path}');
                        await sendChatImage(widget.messageSender, File(i.path));
                      }
                    },
                    icon: Icon(
                      Icons.image_rounded,
                      color: Colors.teal.shade800,
                      size: 28,
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        debugPrint('Image Path: ${image.path}');

                        await sendChatImage(
                            widget.messageSender, File(image.path));
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.teal.shade800,
                      size: 28,
                    ),
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
                  Message msg = Message(
                    sender: loggedInUser.uid,
                    content: message,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    type: MessageType.text,
                  );
                  loggedInUser.sendMessageToUser(widget.messageSender, msg);
                  _controller.clear();
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  }
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
        ],
      ),
    );
  }

  // send image message
  Future<void> sendChatImage(User chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = FirebaseStorage.instance.ref().child(
        'images/${getChatId(chatUser.uid, loggedInUser.uid)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((taskSnapshot) {
      debugPrint(
          'Data Transferred: ${taskSnapshot.bytesTransferred / 1024} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    final message = Message(
      content: imageUrl,
      sender: loggedInUser.uid,
      type: MessageType.image,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    loggedInUser.sendMessageToUser(chatUser, message);
  }
}
