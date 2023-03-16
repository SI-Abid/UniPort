import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../services/helper.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';
import '../services/providers.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
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
                  navigateOnLogin(context, email, password);
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

  Future<dynamic> navigateOnLogin(
      BuildContext context, String email, String password) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FutureBuilder(
          future: loggedInUser.loginWithEmail(email, password),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == true) {
                if (loggedInUser.approved!) {
                  return const HomeScreen();
                }
                Fluttertoast.showToast(
                    msg: "Your registration is waiting for approval",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                loggedInUser.signOut();
                return const LoginScreen();
              } else {
                Fluttertoast.showToast(
                    msg: "Invalid Email or Password",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                loggedInUser.signOut();
                return const LoginScreen();
              }
            }
            return FutureBuilder(
              future: Connectivity().checkConnectivity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == ConnectivityResult.none) {
                    Fluttertoast.showToast(
                        msg: "No Internet Connection",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    loggedInUser.signOut();

                    return const LoginScreen();
                  }
                }
                return const LoadingScreen();
              },
            );
          },
        ),
      ),
      (route) => false,
    );
  }
}
