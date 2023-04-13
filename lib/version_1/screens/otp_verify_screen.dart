import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/providers/otp_controller.dart';

import '../widgets/widgets.dart';

class OtpVerifyScreen extends StatefulWidget {
  static const routeName = '/otp-verify';
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ColorConstant.teal700,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OtpVerifyHeader(email: widget.email),
                const SizedBox(height: 40),
                OtpVerifyBody(email: widget.email),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpVerifyHeader extends StatelessWidget {
  final String email;
  const OtpVerifyHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SvgHeader(
          path: 'assets/images/img_mail.svg',
        ),
        const SizedBox(height: 15),
        Text(
          'Please Enter 6 Digit Code Sent',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'to $email',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class SvgHeader extends StatelessWidget {
  final String path;
  const SvgHeader({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: SvgPicture.asset(
        path,
        fit: BoxFit.contain,
        height: 60,
        width: 60,
      ),
    );
  }
}

class OtpVerifyBody extends StatelessWidget {
  OtpVerifyBody({super.key, required this.email});
  final String email;
  final List<TextEditingController> digitControllers =
      List.filled(6, TextEditingController());
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 310,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SingleDigitField(controller: digitControllers[0]),
                SingleDigitField(controller: digitControllers[1]),
                SingleDigitField(controller: digitControllers[2]),
                SingleDigitField(controller: digitControllers[3]),
                SingleDigitField(controller: digitControllers[4]),
                SingleDigitField(controller: digitControllers[5]),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Didn\'t receive the code?',
              style: GoogleFonts.sen(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Consumer(
              builder: (context, ref, child) => GestureDetector(
                onTap: () {
                  int state = ref.read(countDownProvider);
                  if (state == 0) {
                    ref.read(countDownProvider.notifier).startCountDown();
                    ref
                        .read(otpControllerProvider)
                        .sendOtp(context, email: email);
                  }
                },
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.sen(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ref.read(countDownProvider) == 0
                        ? ColorConstant.teal700
                        : Colors.grey.withOpacity(0.5),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const CounterDown(),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) => ActionButton(
                text: 'VERIFY',
                onPressed: () {
                  String otp = digitControllers.map((e) => e.text).join();
                  ref
                      .read(otpControllerProvider)
                      .verifyOtp(context, email: email, otp: otp);
                  // print('OTP Verified');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SingleDigitField extends StatelessWidget {
  const SingleDigitField({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 40,
      child: TextFormField(
        controller: controller,
        onChanged: ((value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        }),
        style: GoogleFonts.sen(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: ColorConstant.teal700,
        ),
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.bottom,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          hintText: '0',
          counterText: '',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorConstant.cyan700,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: ColorConstant.cyan700,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
