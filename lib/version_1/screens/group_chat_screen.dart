import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniport/version_1/providers/chat_controller.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class GroupChatScreen extends StatefulWidget {
  static const String routeName = '/group_chat_screen';
  const GroupChatScreen(
      {super.key, required this.groupId, required this.title});
  final String groupId;
  final String title;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorConstant.teal700,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.sen(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: ColorConstant.teal700,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: GroupChatBody(groupId: widget.groupId),
          ),
        ),
      ),
    );
  }
}

class GroupChatBody extends ConsumerStatefulWidget {
  const GroupChatBody({super.key, required this.groupId});
  final String groupId;

  @override
  ConsumerState<GroupChatBody> createState() => _GroupChatBodyState();
}

class _GroupChatBodyState extends ConsumerState<GroupChatBody> {
  bool _showEmoji = false;
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<GroupMessage>>(
            stream: ref
                .watch(chatControllerProvider)
                .groupChatStream(groupId: widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.hasData == false) {
                return const Center(child: Text('No messages yet'));
              }
              final messages = snapshot.data!;
              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return GroupMessageTile(
                    sender: messages[index].sender,
                    message: messages[index].message,
                  );
                },
              );
            },
          ),
        ),
        _chatInput(MediaQuery.of(context).size, context, ref),
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
    );
  }

  Padding _chatInput(Size mq, BuildContext context, WidgetRef ref) {
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
                        // DONE: send image to group chat
                        ref.read(chatControllerProvider).sendGroupImage(
                            groupId: widget.groupId, path: i.path);
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
                        // DONE: send image to group chat
                        ref.read(chatControllerProvider).sendGroupImage(
                            groupId: widget.groupId, path: image.path);
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
                  // DONE: send message to group chat
                  ref
                      .read(chatControllerProvider)
                      .sendGroupMessage(groupId: widget.groupId, text: message);
                }
                _controller.clear();
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

class GroupMessageTile extends StatelessWidget {
  const GroupMessageTile(
      {super.key, required this.message, required this.sender});
  final Message message;
  final UserModel sender;
  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == sender.uid;
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
                  child: Avatar(user: sender, size: 12),
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

          message.type == MessageType.text
              ? GestureDetector(
                  onLongPress: () {
                    // text copy to clipboard
                    Clipboard.setData(ClipboardData(text: message.content))
                        .then((value) => Fluttertoast.showToast(
                            msg: 'Copied to Clipboard',
                            backgroundColor: Colors.grey.shade700,
                            textColor: Colors.white,
                            fontSize: 16,
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT));
                  },
                  child: Container(
                    margin: isMe
                        ? const EdgeInsets.only(left: 55)
                        : const EdgeInsets.only(right: 55),
                    padding:
                        message.content.contains(RegExp(r'[^\u0000-\u007F]'))
                            ? const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 10,
                                right: 10,
                              )
                            : const EdgeInsets.only(
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
                        fontSize: message.content
                                .contains(RegExp(r'[^\u0000-\u007F]'))
                            ? 22
                            : 16,
                        fontWeight: FontWeight.w500,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )
              // Image
              : Container(
                  margin: isMe
                      ? const EdgeInsets.only(left: 55)
                      : const EdgeInsets.only(right: 55),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageScreen(
                                    imageUrl: message.content,
                                  )));
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(0))),
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        message.content,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.teal.shade800,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return const Material(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Icon(
                              Icons.image,
                              color: Colors.red,
                              size: 50,
                            ),
                          );
                        },
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
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
