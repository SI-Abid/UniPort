import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/helper.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class SetPasswordRegScreen extends StatelessWidget {
  const SetPasswordRegScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorConstant.teal700),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                SetPasswordHeaderText(),
                SizedBox(height: 40),
                SetPasswordBody()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SetPasswordHeaderText extends StatefulWidget {
  const SetPasswordHeaderText({Key? key}) : super(key: key);

  @override
  State<SetPasswordHeaderText> createState() => _SetPasswordHeaderTextState();
}

class _SetPasswordHeaderTextState extends State<SetPasswordHeaderText> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Set Your Password",
        style: GoogleFonts.sen(
          letterSpacing: 0.5,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: ColorConstant.teal700,
        ),
      ),
    );
  }
}

class SetPasswordBody extends StatefulWidget {
  const SetPasswordBody({super.key});

  @override
  State<SetPasswordBody> createState() => _SetPasswordBodyState();
}

class _SetPasswordBodyState extends State<SetPasswordBody> {
  final passwordController = TextEditingController();

  final confirmPassController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

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
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Password Text Field
              PasswordField(
                controller: passwordController,
                hintText: 'Password',
                formValidator: passwordValidator,
              ),
              const SizedBox(height: 5),
              PasswordField(
                controller: confirmPassController,
                hintText: 'Confirm Password',
                formValidator: passwordValidator,
              ),
              const SizedBox(height: 10),
              ActionButton(
                text: 'CONFIRM',
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  String pass = passwordController.text.trim();
                  String conp = confirmPassController.text.trim();
                  if (pass != conp) {
                    Fluttertoast.showToast(
                      msg: 'Password does not match',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return;
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FutureBuilder(
                          future: createUser(pass),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == true) {
                                Fluttertoast.showToast(
                                  msg: 'Registration Successful',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                return const LoginScreen();
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'Registration Failed',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                                // FirebaseAuth.instance.currentUser!.delete();
                                return const LoginScreen();
                              }
                            }
                            return const LoadingScreen();
                          },
                        ),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
