import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

import '../models/models.dart';
import '../services/helper.dart';

class MessageTile extends StatelessWidget {
  const MessageTile({super.key, required this.message, required this.isMe});
  final Message message;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 0 : MediaQuery.of(context).size.width * 0.015,
        right: isMe ? MediaQuery.of(context).size.width * 0.015 : 0,
      ),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
