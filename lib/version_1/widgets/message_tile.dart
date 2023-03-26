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
      this.nextMsg,
      required this.isLast,
      this.prevMsg});
  final Message message;
  final bool isMe;
  final String chatId;
  final Message? nextMsg;
  final Message? prevMsg;
  final bool isLast;
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
            child: message.type == MessageType.text
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
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(0)),
                      ),
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
    final mq = MediaQuery.of(context).size;
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 3,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8)),
              ),

              message.type == MessageType.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: message.content))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Fluttertoast.showToast(
                              msg: 'Text Copied!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey[700],
                              textColor: Colors.white,
                              fontSize: 16.0);
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          debugPrint('Image Url: ${message.content}');
                          await GallerySaver.saveImage(message.content,
                                  albumName: 'We Chat')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Fluttertoast.showToast(
                                  msg: 'Image Saved!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.grey[700],
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            }
                          });
                        } catch (e) {
                          debugPrint('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (message.type == MessageType.text && isMe)
                _OptionItem(
                    icon:
                        const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                      _showMessageUpdateDialog(context);
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      message.delete(chatId, isLast, prevMsg);
                      Navigator.pop(context);
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name: 'Sent At: ${formatTime(message.createdAt)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: message.readAt == null
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${formatTime(message.readAt!)}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog(BuildContext context) {
    String updatedMsg = message.content;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        //title
        title: Row(
          children: const [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Update Message')
          ],
        ),

        //content
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),

        //actions
        actions: [
          //cancel button
          MaterialButton(
            onPressed: () {
              //hide alert dialog
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),

          //update button
          MaterialButton(
            onPressed: () {
              //hide alert dialog
              Navigator.pop(context);
              message.update(updatedMsg, chatId, isLast);
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                '    $name',
                style: const TextStyle(
                    fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
              ),
            )
          ],
        ),
      ),
    );
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
