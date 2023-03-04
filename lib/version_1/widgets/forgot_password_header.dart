import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'RESET PASSWORD',
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 22,
            fontWeight: FontWeight.normal,
            color: const Color.fromARGB(255, 8, 173, 123),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Enter your academic E-mail\nto get an OTP',
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
