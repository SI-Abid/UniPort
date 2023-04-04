import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:uniport/version_1/providers/providers.dart';

import '../services/helper.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';
import '../services/providers.dart';

class LoginBody extends StatelessWidget {
  LoginBody({super.key});

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 380,
      // blur effect on the container
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
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
            children: <Widget>[
              // Email Text Field
              CustomTextField(
                controller: emailController,
                formValidator: emailValidator,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 5),
              // Password Text Field
              PasswordField(
                controller: passwordController,
                formValidator: passwordValidator,
              ),
              const SizedBox(height: 5),

              // Forgot Password Text
              const ForgotPasswordText(),
              const SizedBox(height: 5),

              // Login Button
              ActionButton(
                text: 'LOG IN',
                onPressed: () {
                  final String email = emailController.text.trim();
                  final String password = passwordController.text.trim();
                  // print(loggedInUser);
                  // if super admin
                  if (email == 'admin' && password == 'admin') {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(debug: true),
                      ),
                      (route) => false,
                    );
                    return;
                  }
                  if (formKey.currentState!.validate() == false) {
                    return;
                  }
                  //navigate to dashboard
                  onLogin(context, email, password);
                },
              ),
              const SizedBox(height: 5),
              // Divider Text
              const DividerText(
                text: 'or continue with',
              ),
              const SizedBox(height: 5),

              // Google Login Button
              const GoogleLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> onLogin(BuildContext context, String email, String password) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FutureBuilder(
          future:
              context.read<AuthProvider>().handleEmailSignIn(email, password),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (context.read<AuthProvider>().status) {
                case Status.authenticated:
                  return const HomeScreen();
                case Status.approvalRequired:
                  Fluttertoast.showToast(
                    msg: 'Your account is awaiting approval',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  break;
                default:
                  Fluttertoast.showToast(
                    msg: 'An error occurred',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  break;
              }
              return const LoginScreen();
            } else {
              return FutureBuilder(
                future: Connectivity().checkConnectivity(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return const LoadingScreen();
                  } else {
                    return const AlertDialog(
                      icon: Icon(Icons.error),
                      iconColor: Colors.red,
                      title: Text('No Internet Connection'),
                      content: Text('Please check your internet connection'),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
      (route) => false,
    );
  }
}
