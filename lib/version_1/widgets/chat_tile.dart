import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/services/providers.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class ChatTile extends StatelessWidget {
  const ChatTile(
      {super.key,
      required this.lastMsg,
      required this.messageSender});

  final Message lastMsg;
  final User messageSender;

  @override
  Widget build(BuildContext context) {
    bool isMe = lastMsg.sender == loggedInUser.uid;
    bool isUnread = lastMsg.readAt == null && !isMe;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/message', arguments: messageSender);
        },
        leading: Avatar(messageSender: messageSender),
        title: Text(
          messageSender.name,
          softWrap: true,
          maxLines: 1,
          style: GoogleFonts.sen(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: lastMsg.type == 0
            ? Text(
                '${isMe ? 'You: ' : ''}${lastMsg.content}',
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
              formatTime(lastMsg.createdAt),
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
