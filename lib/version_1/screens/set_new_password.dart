import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/providers/otp_controller.dart';

import '../widgets/widgets.dart';

class SetNewPasswordScreen extends StatefulWidget {
  static const routeName = '/setNewPassword';

  const SetNewPasswordScreen({super.key});
  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
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
              //mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                SetNewPasswordHeader(),
                SizedBox(height: 40),
                SetNewPasswordBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetNewPasswordHeader extends StatelessWidget {
  const SetNewPasswordHeader({Key? key}) : super(key: key);

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
            'assets/images/img_secured.svg',
            fit: BoxFit.contain,
            height: 60,
            width: 60,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Create New Password. Your New',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Password Must Be Different From',
          textAlign: TextAlign.center,
          style: GoogleFonts.sen(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Previous Password.',
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

class SetNewPasswordBody extends StatefulWidget {
  const SetNewPasswordBody({super.key});

  @override
  State<SetNewPasswordBody> createState() => _SetNewPasswordBodyState();
}

class _SetNewPasswordBodyState extends State<SetNewPasswordBody> {
  final passwordController = TextEditingController();

  final confirmPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 300,
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
          children: [
            // Password Text Field
            PasswordField(
              controller: passwordController,
              hintText: 'Password',
            ),
            PasswordField(
              controller: confirmPassController,
              hintText: 'Confirm Password',
            ),
            Consumer(
              builder: (context, ref, child) => ActionButton(
                text: 'CONFIRM',
                onPressed: () {
                  if (passwordController.text.isEmpty ||
                      confirmPassController.text.isEmpty) {
                    Fluttertoast.showToast(
                      msg: 'Please fill all the fields',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else if (passwordController.text !=
                      confirmPassController.text) {
                    Fluttertoast.showToast(
                      msg: 'Password does not match',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    ref.read(otpControllerProvider).setPassword(context,
                        password: passwordController.text.trim());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
