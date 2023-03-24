import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import '../models/models.dart';
import '../services/helper.dart';

class MessageTile extends StatelessWidget {
  const MessageTile(
      {super.key,
      required this.message,
      required this.isMe,
      required this.chatId,
      this.nextMsg});
  final Message message;
  final bool isMe;
  final String chatId;
  final Message? nextMsg;
  @override
  Widget build(BuildContext context) {
    if (!isMe && message.readAt == null) {
      message.markAsRead(chatId);
    }
    return Container(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isMe ? 0 : MediaQuery.of(context).size.width * 0.02,
        right: isMe ? MediaQuery.of(context).size.width * 0.02 : 0,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              // text copy to clipboard
              _getMessageAction(context);
            },
            child: message.type == 0
                ? Container(
                    margin: isMe
                        ? const EdgeInsets.only(left: 55)
                        : const EdgeInsets.only(right: 55),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: isMe
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            )
                          : const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
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
          ),
          const SizedBox(height: 2),
          isMe
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      formatTime(message.createdAt),
                      style: GoogleFonts.sen(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                    const SizedBox(width: 5),
                    message.readAt == null
                        ? Icon(
                            Icons.done,
                            size: 12,
                            color: Colors.teal.shade800,
                          )
                        : Icon(
                            Icons.done_all,
                            size: 12,
                            color: Colors.teal.shade800,
                          )
                  ],
                )
              : message.sender != nextMsg?.sender
                  ? Text(
                      formatTime(message.createdAt),
                      style: GoogleFonts.sen(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    )
                  : DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                              .minute !=
                          DateTime.fromMillisecondsSinceEpoch(
                                  nextMsg!.createdAt)
                              .minute
                      ? Text(
                          formatTime(message.createdAt),
                          style: GoogleFonts.sen(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        )
                      : const SizedBox.shrink()
        ],
      ),
    );
  }

  Future<dynamic> _getMessageAction(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (context) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                message.type == 0
                    ? ListTile(
                        leading: const Icon(Icons.copy),
                        title: const Text('Copy'),
                        onTap: () {
                          // hide bottom sheet
                          Navigator.pop(context);
                          Clipboard.setData(
                                  ClipboardData(text: message.content))
                              .then((value) => Fluttertoast.showToast(
                                  msg: 'Copied to Clipboard',
                                  backgroundColor: Colors.grey.shade700,
                                  textColor: Colors.white,
                                  fontSize: 16,
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT));
                        },
                      )
                    : ListTile(
                        leading: const Icon(Icons.save),
                        title: const Text('Save'),
                        onTap: () {
                          GallerySaver.saveImage(message.content).then(
                              (value) => Fluttertoast.showToast(
                                  msg: 'Saved to Gallery',
                                  backgroundColor: Colors.grey.shade700,
                                  textColor: Colors.white,
                                  fontSize: 16,
                                  gravity: ToastGravity.BOTTOM,
                                  toastLength: Toast.LENGTH_SHORT));
                        },
                      ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                  ),
                ),
                if (isMe)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () {
                      // hide bottom sheet
                      Navigator.pop(context);
                      // delete message
                      message.delete(chatId);
                    },
                  ),
              ],
            ),
          );
        });
  }
}

class ImageScreen extends StatefulWidget {
  final String imageUrl;
  const ImageScreen({super.key, required this.imageUrl});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  int _turns = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // rotate image
          IconButton(
            onPressed: () {
              setState(() {
                _turns = (_turns + 1) % 4;
              });
            },
            icon: Icon(Icons.rotate_right_outlined,
                color: Colors.teal.shade800, size: 30),
          ),
          IconButton(
            onPressed: () {
              // download image
              GallerySaver.saveImage(widget.imageUrl, albumName: 'UniPort')
                  .then((value) {
                debugPrint('Image path: ${widget.imageUrl}');
                if (value == true) {
                  Fluttertoast.showToast(
                      msg: 'Image Saved',
                      backgroundColor: Colors.grey.shade700,
                      textColor: Colors.white,
                      fontSize: 16,
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT);
                } else {
                  Fluttertoast.showToast(
                      msg: 'Error Occured',
                      backgroundColor: Colors.grey.shade700,
                      textColor: Colors.white,
                      fontSize: 16,
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT);
                }
              });
            },
            icon: Icon(Icons.download, color: Colors.teal.shade800, size: 30),
          ),
        ],
      ),
      body: PinchZoom(
        resetDuration: const Duration(hours: 1),
        // maxScale: 2.5,
        child: Center(
          child: RotatedBox(
            quarterTurns: _turns,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}
