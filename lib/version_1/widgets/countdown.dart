import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CounterDown extends StatefulWidget {
  const CounterDown({
    Key? key,
  }) : super(key: key);

  @override
  State<CounterDown> createState() => _CounterDownState();
}

class _CounterDownState extends State<CounterDown>
    with SingleTickerProviderStateMixin {
  // create a timer from 30 to 0
  late AnimationController controller;
  late Animation<int> animation;
  int counter = 30;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    animation = IntTween(begin: 30, end: 0).animate(controller)
      ..addListener(() {
        setState(() {
          counter = animation.value;
        });
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      padding: const EdgeInsets.all(15),
      dashPattern: const [5, 5],
      color: const Color.fromARGB(255, 0, 114, 80),
      strokeWidth: 1,
      borderType: BorderType.Circle,
      child: Text(
        counter.toString().padLeft(2, '0'),
        style: GoogleFonts.sen(
          letterSpacing: 0.5,
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: const Color.fromARGB(255, 0, 114, 80),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
