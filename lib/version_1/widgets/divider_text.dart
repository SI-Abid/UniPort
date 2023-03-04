import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DividerText extends StatelessWidget {
  final String text;
  const DividerText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 75,
          child: Divider(
            color: Color.fromARGB(255, 70, 70, 70),
            thickness: 0.5,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(255, 70, 70, 70),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        const SizedBox(
          width: 75,
          child: Divider(
            color: Color.fromARGB(255, 70, 70, 70),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}
