import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

final countDownProvider =
    StateNotifierProvider<CountDown, int>((ref) => CountDown());

class CountDown extends StateNotifier<int> {
  CountDown() : super(30);

  void startCountDown() {
    state = 30;
  }

  void decrement() {
    state--;
  }
}

class CounterDown extends ConsumerStatefulWidget {
  const CounterDown({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CounterDown> createState() => _CounterDownState();
}

class _CounterDownState extends ConsumerState<CounterDown>
    with SingleTickerProviderStateMixin {
  // create a timer from 30 to 0
  late AnimationController controller;
  late Animation<int> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    animation = IntTween(begin: 30, end: 0).animate(controller)
      ..addListener(() {
        ref.read(countDownProvider.notifier).decrement();
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
    int state = ref.watch(countDownProvider);
    if (state == 30) {
      controller.forward();
    } else if (state == 0) {
      controller.stop();
    }
    return DottedBorder(
      padding: const EdgeInsets.all(15),
      dashPattern: const [5, 5],
      color: const Color.fromARGB(255, 0, 114, 80),
      strokeWidth: 1,
      borderType: BorderType.Circle,
      child: Text(
        state.toString().padLeft(2, '0'),
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
