import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({
    super.key,
  });

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  final bellOn = SvgPicture.asset(
    'assets/icon/notification.svg',
    color: Colors.teal.shade800,
    height: 20,
    width: 20,
  );
  final bellOff = SvgPicture.asset(
    'assets/icon/notification_mutted.svg',
    color: Colors.teal.shade800,
    height: 20,
    width: 20,
  );
  bool isBellOn = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isBellOn = !isBellOn;
        });
      },
      child: Card(
        elevation: 2,
        shape: const CircleBorder(),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          child: isBellOn ? bellOn : bellOff,
        ),
      ),
    );
  }
}
