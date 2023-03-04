import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/callback_function.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class EmailVerifyScreen extends StatelessWidget {
  const EmailVerifyScreen({super.key});

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
              children: const <Widget>[
                EmailVerifyHeader(),
                SizedBox(height: 40),
                EmailVerifyBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailVerifyHeader extends StatelessWidget {
  const EmailVerifyHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
            'assets/images/img_lock.svg',
            fit: BoxFit.contain,
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Please Enter Your E-mail To',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Recieve Verification Code',
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

class EmailVerifyBody extends StatefulWidget {
  const EmailVerifyBody({super.key});

  @override
  State<EmailVerifyBody> createState() => _EmailVerifyBodyState();
}

class _EmailVerifyBodyState extends State<EmailVerifyBody> {
  final emailController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 200,
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
            ActionButton(
              text: 'SEND E-MAIL',
              onPressed: () async {
                final email = emailController.text.trim();
                if(email.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please enter your email',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  return;
                }
                await onOtpRequest(email).then((value) {
                  if (value == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpVerifyScreen(
                          email: email,
                        ),
                      ),
                    );
                  } else {
                    // print('OTP Request Failed');
                    Fluttertoast.showToast(
                      msg: 'Email not registered',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
