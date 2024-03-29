import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniport/version_1/providers/chat_controller.dart';
import 'package:uniport/common/toast.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class MessageScreen extends StatefulWidget {
  static const String routeName = '/message_screen';
  const MessageScreen({super.key, required this.messageSender});
  final UserModel messageSender;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _controller = TextEditingController();

  late UserModel messageReciever;
  int count = 0;
  bool profileViewed = false;

  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    messageReciever = widget.messageSender;
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Avatar(user: messageReciever),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageReciever.name,
                    style: GoogleFonts.sen(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('onlineStatus')
                        .doc(messageReciever.uid)
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
          iconTheme: IconThemeData(color: Colors.teal[800]),
          actions: [
            Consumer(builder: (context, ref, child) {
              return PopupMenuButton(
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
                    // ref.read(chatControllerProvider).deleteChat(chatId: widget.chatRoomId);
                    unavailableFeatureToast();
                  }
                },
              );
            }),
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
                      MessageList(recieverId: messageReciever.uid),
                      if (profileViewed)
                        ProfileCard(messageSender: messageReciever),
                    ],
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  return chatInput(mq, context, ref);
                },
              ),
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

  Padding chatInput(Size mq, BuildContext context, WidgetRef ref) {
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
                        ref.read(chatControllerProvider).sendImage(
                            recieverId: messageReciever.uid, path: i.path);
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

                        ref.read(chatControllerProvider).sendImage(
                            recieverId: messageReciever.uid, path: image.path);
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
                  ref.read(chatControllerProvider).sendMessage(
                      recieverId: messageReciever.uid, text: message);
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
        ],
      ),
    );
  }
}

class MessageList extends ConsumerStatefulWidget {
  final String recieverId;
  const MessageList({required this.recieverId, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: ref
          .read(chatControllerProvider)
          .chatStream(recieverId: widget.recieverId),
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasData == false) {
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
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
        final messageList = snapshot.data!;
        return ListView.builder(
          reverse: true, // * MESSAGE LIST IS REVERSED
          controller: _scrollController,
          itemCount: messageList.length,
          itemBuilder: (context, index) {
            final message = messageList[index];
            final nextMssg = index == 0 ? null : messageList[index - 1];
            final prevMssg =
                index == messageList.length - 1 ? null : messageList[index + 1];
            bool isMe = message.sender != widget.recieverId;
            return MessageTile(
              message: message,
              isMe: isMe,
              nextMsg: nextMssg,
              prevMsg: prevMssg,
              isLast: index == 0,
            );
          },
        );
      },
    );
  }
}
