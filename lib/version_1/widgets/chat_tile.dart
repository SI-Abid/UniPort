import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class ChatTile extends StatelessWidget {
  const ChatTile(
      {super.key,
      required this.lastMsg,
      required this.messageSender,
      required this.isUnread});

  final Message lastMsg;
  final MessageSender messageSender;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: lastMsg.type == 0
            ? Text(
                lastMsg.content,
                softWrap: true,
                maxLines: 1,
                style: GoogleFonts.sen(
                  color: Colors.black,
                  fontSize: 14,
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
          children: [
            Text(
              formatTime(lastMsg.createdAt),
              style: GoogleFonts.sen(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.green.shade500,
                borderRadius: BorderRadius.circular(25),
              ),
            )
          ],
        ),
      ),
    );
  }
}
