import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.user, this.size = 20});
  final double size;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * 2,
      width: size * 2,
      decoration: BoxDecoration(
        border: Border.all(
          color: user?.usertype == 'student' ? Colors.green : Colors.blue,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(size * 2),
      ),
      child: user!.photoUrl == null
          ? CircleAvatar(
              radius: size,
              backgroundColor: Colors.brown.shade800,
              child: Text(user!.name[0].toUpperCase()))
          : CircleAvatar(
              radius: size,
              backgroundColor: Colors.brown.shade800,
              child: ClipOval(
                child: CachedNetworkImage(imageUrl: user!.photoUrl!),
              ),
            ),
    );
  }
}
