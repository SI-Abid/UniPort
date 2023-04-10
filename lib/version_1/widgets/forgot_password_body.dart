import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/providers/otp_controller.dart';

import '../widgets/widgets.dart';

class ForgotPasswordBody extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  ForgotPasswordBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 280,
      // blur effect on the container
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Email Text Field
            CustomTextField(controller: emailController),

            Consumer(
              builder: (context, ref, child) => ActionButton(
                  text: 'Send OTP',
                  onPressed: () {
                    ref
                        .read(otpControllerProvider)
                        .sendOtp(context, email: emailController.text.trim());
                  }),
            ),

            // timer
            DottedBorder(
              padding: const EdgeInsets.all(15),
              borderType: BorderType.Circle,
              radius: const Radius.circular(50),
              color: const Color.fromARGB(255, 0, 114, 80),
              strokeWidth: 0.5,
              dashPattern: const [5, 5],
              child: const CounterDown(),
            ),
          ],
        ),
      ),
    );
  }
}
