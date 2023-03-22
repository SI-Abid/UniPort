import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen(
      {super.key, required this.groupId, required this.title});
  final String groupId;
  final String title;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<QueryDocumentSnapshot> messages;
  int _limit = 20;
  final int _limitIncrement = 20;
  bool _showEmoji = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppTitle(title: 'Advisor ${widget.title}'),
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        backgroundColor: const Color(0xaaf3f3f3),
        elevation: 0,
        actions: [
          // more_vert
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
                child: Text('View Info'),
              ),
              if (loggedInUser.usertype == 'teacher')
                const PopupMenuItem(
                  value: 2,
                  child: Text('Delete Group'),
                ),
            ],
            onSelected: (value) {
              if (value == 1) {
              } else if (value == 2) {
                FirebaseFirestore.instance
                    .collection('advisor groups')
                    .doc(widget.groupId)
                    .delete();
                FirebaseStorage.instance
                    .ref()
                    .child('images/${widget.groupId}')
                    .delete();
              }
            },
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('advisor groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData == false) {
                  return const SizedBox.shrink();
                }
                messages = snapshot.data!.docs;
                return Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = Message.fromJson(
                          messages[index].data() as Map<String, dynamic>);
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(message.sender)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData == false) {
                            return const SizedBox.shrink();
                          }
                          final user = User.fromJson(
                              snapshot.data!.data() as Map<String, dynamic>);
                          return GroupMessageTile(
                              message: message, sender: user);
                        },
                      );
                    },
                  ),
                );
              },
            ),
            _chatInput(context),
            if (_showEmoji)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
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
              ),
          ],
        ),
      ),
    );
  }

  Padding _chatInput(BuildContext context) {
    final mq = MediaQuery.of(context).size;
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
                      _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                      color: Colors.teal.shade800,
                    ),
                    onPressed: () {
                      if (_showEmoji) {
                        setState(() => _showEmoji = false);
                        FocusScope.of(context).requestFocus(_focusNode);
                      } else {
                        FocusScope.of(context).unfocus();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          setState(() => _showEmoji = true);
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _focusNode,
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
                        FocusScope.of(context).requestFocus(_focusNode);
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
                        // setState(() => _isUploading = true);
                        await sendChatImage(widget.groupId, File(i.path));
                        // setState(() => _isUploading = false);
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
                        // setState(() => _isUploading = true);

                        await sendChatImage(widget.groupId, File(image.path));
                        // setState(() => _isUploading = false);
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
                    type: 0,
                  );
                  loggedInUser.sendMessageToGroup(widget.groupId, msg);
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
  Future<void> sendChatImage(String groupId, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = FirebaseStorage.instance
        .ref()
        .child('images/$groupId/${DateTime.now().millisecondsSinceEpoch}.$ext');

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
      type: 1,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    loggedInUser.sendMessageToGroup(groupId, message);
  }
}

class GroupMessageTile extends StatelessWidget {
  const GroupMessageTile(
      {super.key, required this.message, required this.sender});
  final Message message;
  final User sender;
  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == loggedInUser.uid;
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

          message.type == 0
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
