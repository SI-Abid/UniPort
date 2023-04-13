import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/providers/user_provider.dart';

import '../services/helper.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class LoginBody extends ConsumerStatefulWidget {
  const LoginBody({super.key});

  @override
  ConsumerState<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends ConsumerState<LoginBody> {
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
                  // handle login
                  ref
                      .read(userProvider.notifier)
                      .loginWithEmail(email, password);
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
}
