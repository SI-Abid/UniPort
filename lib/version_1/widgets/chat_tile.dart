import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../screens/message_screen.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.message, required this.otherUser});

  final Message message;
  final UserModel otherUser;

  @override
  Widget build(BuildContext context) {
    bool isMe = message.sender == FirebaseAuth.instance.currentUser!.uid;
    // print('${lastMsg.sender} ${loggedInUser.uid}');
    bool isUnread = message.readAt == null && !isMe;
    return Container(
      color: Colors.white,
      // margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, MessageScreen.routeName,
              arguments: otherUser);
        },
        leading: Avatar(
          user: otherUser,
          size: 22,
        ),
        title: Text(
          otherUser.name,
          softWrap: true,
          maxLines: 1,
          style: GoogleFonts.sen(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: message.type == MessageType.text
            ? Text(
                '${isMe ? 'You: ' : ''}${message.content}',
                softWrap: true,
                maxLines: 1,
                style: GoogleFonts.sen(
                  color: Colors.grey.shade800,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              )
            : Row(
                children: [
                  if (isMe)
                    Text(
                      'You: ',
                      softWrap: true,
                      maxLines: 1,
                      style: GoogleFonts.sen(
                        color: Colors.grey.shade800,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  Icon(
                    Icons.image,
                    color: Colors.teal.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Image',
                    softWrap: true,
                    maxLines: 1,
                    style: GoogleFonts.sen(
                      color: Colors.teal.shade800,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatTime(message.createdAt),
              style: GoogleFonts.sen(
                fontSize: 12,
                fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                color: isUnread ? Colors.teal.shade600 : Colors.black,
              ),
            ),
            Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: isUnread ? Colors.teal.shade600 : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
