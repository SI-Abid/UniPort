import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widgets.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome To ',
              style: GoogleFonts.sen(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const AppTitle(),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Sign in to continue',
          style: GoogleFonts.sen(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
