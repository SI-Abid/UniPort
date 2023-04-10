import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/email_verify_screen.dart';

class ForgotPasswordText extends StatelessWidget {
  const ForgotPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 30,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ForgetPasswordScreen()));
        },
        child: Text(
          'Forgot your password?',
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade400,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
