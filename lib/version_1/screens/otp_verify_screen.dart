import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({super.key, required this.email});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    otpHolder = "";
    super.dispose();
  }

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
  const OtpVerifyBody({super.key, required this.email});
  final String email;
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
              children: const [
                SingleDigitField(),
                SingleDigitField(),
                SingleDigitField(),
                SingleDigitField(),
                SingleDigitField(),
                SingleDigitField(),
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
            Text(
              'Resend Code',
              style: GoogleFonts.sen(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColorConstant.teal700,
                decoration: TextDecoration.underline,
              ),
            ),
            const CounterDown(),
            const SizedBox(height: 20),
            ActionButton(
              text: 'VERIFY',
              onPressed: () {
                // print('Email: $email');
                // print('OTP: $otpHolder');
                if (emailAuth.validateOtp(
                    recipientMail: email, userOtp: otpHolder)) {
                  // print('OTP Verified');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetNewPasswordScreen(
                        email: email,
                      ),
                    ),
                  );
                } else {
                  // print('OTP Not Verified');
                  Fluttertoast.showToast(
                      msg: 'OTP Not Verified',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SingleDigitField extends StatelessWidget {
  const SingleDigitField({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 40,
      child: TextFormField(
        onChanged: ((value) {
          if (value.length == 1) {
            otpHolder += value;
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
            otpHolder = otpHolder.substring(0, otpHolder.length - 1);
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
