import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'helper.dart';
import 'providers.dart';

Future<String> onLoginWithGoogle() async {
  try {
    final creds = await google
        .signIn()
        .then((value) => value!.authentication)
        .then((value) => GoogleAuthProvider.credential(
            accessToken: value.accessToken, idToken: value.idToken));
    // print('google $creds');
    final creden = await FirebaseAuth.instance.signInWithCredential(creds);
    // print('Firebase $creden');
    // print('google $creds');
    // print('firebase $creden');
    loggedInUser.email = creden.user!.email;
    // Commented out for the purpose of testing
    // if (!loggedInUser.email!.endsWith('@lus.ac.bd')) {
    //   loggedInUser = User();
    //   await prefs.remove('user').then((value) => google.signOut());
    //   await FirebaseAuth.instance.currentUser!.delete();
    //   return 'invalid email';
    // }
    // add user to firestore
    await FirebaseFirestore.instance
        .collection('logindata')
        .doc(creden.user!.email)
        .set({
      'idToken': creds.idToken,
      'accessToken': creds.accessToken,
    });
    loggedInUser.uid = FirebaseAuth.instance.currentUser!.uid;
    loggedInUser.photoUrl = FirebaseAuth.instance.currentUser!.photoURL;
    // print('User $loggedInUser');
    // String docId = Crypt.sha256(googleUser.email).toString().substring(3, 18);
    return await loadUser() ? 'success' : 'new user';
    // return creden.additionalUserInfo!.isNewUser ? 'new user' : 'success';
  } catch (e) {
    return e.toString();
  }
}

Future<bool> onLoginWithEmail(String email, String password) async {
  // print('logging in with $email and $password');
  // print('User $loggedInUser');
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } catch (e) {
    return false;
  }
  return await loadUser();
}

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
          .then((value) => signOut()));
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
