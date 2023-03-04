import 'package:flutter/material.dart';

class OpenedEye extends StatelessWidget {
  const OpenedEye({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 24, 143, 121),
      ),
      child: const Icon(
        Icons.visibility,
        color: Colors.white,
      ),
    );
  }
}

class ClosedEye extends StatelessWidget {
  const ClosedEye({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5,
            spreadRadius: 0.1,
          ),
        ],
      ),
      child: const Icon(
        Icons.visibility_off,
        color: Color.fromARGB(255, 24, 143, 121),
      ),
    );
  }
}
