import 'package:flutter/material.dart';

import '../models/user.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.messageSender, this.size = 20});
  final double size;
  final User messageSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * 2,
      width: size * 2,
      decoration: BoxDecoration(
        border: Border.all(
          color:
              messageSender.usertype == 'student' ? Colors.green : Colors.blue,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(size * 2),
      ),
      child: messageSender.photoUrl == null
          ? CircleAvatar(
              radius: size,
              backgroundColor: Colors.brown.shade800,
              child: Text(messageSender.name[0].toUpperCase()))
          : CircleAvatar(
              radius: size,
              backgroundImage: NetworkImage(messageSender.photoUrl!),
            ),
    );
  }
}
