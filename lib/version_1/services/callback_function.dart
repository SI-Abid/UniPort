import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'providers.dart';


Future<bool> onOtpRequest(String email) async {
  // check if email is registered on firebase
  final check = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
  if (check.isEmpty) {
    return false;
  }

  // print('sending otp to $email');
  emailAuth.sendOtp(recipientMail: email);
  return true;
}

Future<void> onPasswordReset(String email, String password) async {
  debugPrint(email);
  debugPrint(password);
  await FirebaseFirestore.instance
      .collection('logindata')
      .doc(email)
      .get()
      .then((value) => FirebaseAuth.instance
          .signInWithCredential(GoogleAuthProvider.credential(
            accessToken: value['accessToken'],
            idToken: value['idToken'],
          ))
          .then((value) =>
              FirebaseAuth.instance.currentUser!.updatePassword(password))
          .then((value) => FirebaseAuth.instance.signOut()));
  Fluttertoast.showToast(
    msg: 'Password changed successfully',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.green,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
