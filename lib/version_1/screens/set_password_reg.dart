import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/user_provider.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class SetPasswordScreen extends ConsumerWidget {
  static const String routeName = '/set-password';
  const SetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: BackButton(
          color: ColorConstant.teal700,
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

class SetPasswordBody extends ConsumerStatefulWidget {
  const SetPasswordBody({super.key});

  @override
  ConsumerState<SetPasswordBody> createState() => _SetPasswordBodyState();
}

class _SetPasswordBodyState extends ConsumerState<SetPasswordBody> {
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
                    ref
                        .read(userProvider.notifier)
                        .registerUser(password: pass);
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
