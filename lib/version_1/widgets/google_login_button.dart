import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniport/version_1/services/providers.dart';

import '../screens/screens.dart';

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
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () => {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => FutureBuilder(
                future: loggedInUser.loginWithGoogle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == 'invalid email') {
                      debugPrint(snapshot.data);
                      Fluttertoast.showToast(
                        msg: 'Only academic email is allowed',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      loggedInUser.signOut();
                      return const LoginScreen();
                    }
                    if (snapshot.data == 'success') {
                      if (loggedInUser.approved == true) {
                        return const HomeScreen();
                      }
                      Fluttertoast.showToast(
                        msg: 'Your account is not approved yet',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      loggedInUser.signOut();
                      return const LoginScreen();
                    } else if (snapshot.data == 'new user') {
                      return const PersonalInfoScreen();
                    } else {
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
