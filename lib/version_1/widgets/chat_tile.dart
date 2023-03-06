import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, required this.data, required this.messageSender});

  final List<Message> data;
  final MessageSender messageSender;

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
          style: GoogleFonts.sen(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          data.last.type == 0 ? data.last.content : 'Image',
          softWrap: true,
          maxLines: 1,
          style: GoogleFonts.sen(
            color: data.last.type == 0 ? Colors.black : Colors.teal.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: Text(
          formatTime(data.last.createdAt),
          style: GoogleFonts.sen(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
