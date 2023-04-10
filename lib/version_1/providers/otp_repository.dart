import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniport/version_1/screens/screens.dart';

import '../constants/secret.dart';

final otpRepositoryProvider = Provider<OtpRepository>(
  (ref) => OtpRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    emailAuth: EmailAuth(sessionName: 'Uniport'),
  ),
);

class OtpRepository {
  final EmailAuth emailAuth;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  OtpRepository({
    required this.emailAuth,
    required this.auth,
    required this.firestore,
  }) {
    emailAuth.config({
      'server': Secret.server,
      'serverKey': Secret.serverKey,
    });
  }

  Future<void> sendOtp(BuildContext context, {required String email}) async {
    final value = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((value) => value.docs.isEmpty);
    if (value) {
      Fluttertoast.showToast(msg: 'Email not registered');
      return;
    }
    emailAuth.sendOtp(recipientMail: email);
    // *** Navigate to OTP Verify Screen ***
    if (context.mounted) {
      Navigator.pushNamed(context, OtpVerifyScreen.routeName, arguments: email);
    }
  }

  Future<void> verifyOtp(BuildContext context,
      {required String email, required String otp}) async {
    bool verified = emailAuth.validateOtp(recipientMail: email, userOtp: otp);
    if (verified) {
      // *** Navigate to Set Password Screen ***
      firestore
          .collection('logindata')
          .doc(email)
          .get()
          .then((value) => value.data())
          .then((creds) => GoogleAuthProvider.credential(
              idToken: creds!['idToken'], accessToken: creds['accessToken']))
          .then((authCreds) => auth.signInWithCredential(authCreds));
      if (context.mounted) {
        Navigator.pushNamed(context, SetPasswordScreen.routeName);
      }
    } else {
      // *** Show Error Message ***
      Fluttertoast.showToast(msg: 'Invalid OTP');
    }
  }

  Future<void> setNewPassword(BuildContext context,
      {required String password}) async {
    await auth.currentUser?.updatePassword(password);
    // await auth.currentUser?.sendEmailVerification();
    await auth.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);
    }
  }
}
