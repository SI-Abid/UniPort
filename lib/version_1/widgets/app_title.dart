import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.title='UNIPORT'});

  final String title;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          colors: [
            Color.fromARGB(255, 24, 143, 121),
            Color.fromARGB(255, 18, 196, 200),
            Color.fromARGB(255, 4, 160, 188),
          ],
        ).createShader(rect);
      },
      child: Text(
        title,
        style: GoogleFonts.sen(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
