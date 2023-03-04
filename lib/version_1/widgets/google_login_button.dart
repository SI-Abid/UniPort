import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screens/screens.dart';
import '../services/callback_function.dart';
import '../services/helper.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(5),
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
        ),
        onPressed: () => {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: onLoginWithGoogle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == 'success') {
                      return const HomeScreen();
                    } else if (snapshot.data == 'new user') {
                      return const PersonalInfoScreen();
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Only academic email is allowed',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      signOut();
                      return const LoginScreen();
                    }
                  }
                  return const LoadingScreen();
                },
              ),
            ),
            (route) => false,
          ),
        },
        child: SvgPicture.asset(
          alignment: Alignment.bottomCenter,
          'assets/images/logo_google_icon.svg',
          height: 35,
        ),
      ),
    );
  }
}
