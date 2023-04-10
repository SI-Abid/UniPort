import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniport/version_1/screens/academic_info_reg.dart';
import 'package:uniport/version_1/screens/home_screen.dart';
import 'package:uniport/version_1/screens/login_screen.dart';
import 'package:uniport/version_1/screens/personal_info_screen.dart';
import 'package:uniport/version_1/screens/set_password_reg.dart';

import '../models/models.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
    firestore: FirebaseFirestore.instance,
    emailAuth: EmailAuth(sessionName: 'Uniport'),
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  final EmailAuth emailAuth;

  final Map<String, dynamic> _userdata = {};

  AuthRepository({
    required this.emailAuth,
    required this.auth,
    required this.googleSignIn,
    required this.firestore,
  });

  Future<UserModel?> getUser() async {
    // final prefs = await SharedPreferences.getInstance();
    // if(prefs.getString('userData') != null) {
    //   return UserModel.fromJson(jsonDecode(prefs.getString('userData')!));
    // }
    final userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    if (userData.data() == null) {
      return null;
    }
    // prefs.setString('userData', jsonEncode(userData.data()));
    return UserModel.fromJson(userData.data()!);
  }

  // *** SIGN IN WITH GOOGLE ***
  Future<void> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // *** USER CANCELLED SIGN IN ***
      return;
    }
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    final User? user = authResult.user;
    if (user == null) {
      // *** FAILSAFE ***
      return;
    }
    // *** SAVE LOGIN CREDENTIALS
    firestore.collection('logindata').doc(user.email).set({
      'idToken': googleAuth.idToken,
      'accessToken': googleAuth.accessToken,
    });
    QuerySnapshot result = await firestore
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .get();
    List<DocumentSnapshot> documents = result.docs;
    if (documents.isEmpty) {
      // *** NEW USER ***
      // *** NAVIGATE TO SIGN UP SCREEN ***
      // DONE: Navigate to sign up screen
      if (context.mounted) {
        Navigator.pushNamed(context, PersonalInfoScreen.routeName);
      }
    } else {
      // *** EXISTING USER ***
      // *** NAVIGATE TO HOME SCREEN ***
      // DONE: Navigate to home screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);
      }
    }
  }

  // *** SIGN IN WITH EMAIL ***
  Future<void> signInWithEmail(BuildContext context,
      {required String email, required String password}) async {
    try {
      User? user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user == null) {
        // *** FAILSAFE ***
        return;
      }
      DocumentSnapshot result =
          await firestore.collection('users').doc(user.uid).get();
      if (result.exists == false) {
        // *** USER REGISTERED BUT NO DATA ***
        // *** NAVIGATE TO SIGN UP SCREEN ***
        // DONE: Navigate to sign up screen
        if (context.mounted) {
          Navigator.pushNamed(context, PersonalInfoScreen.routeName);
        }
        return;
      }
      // *** NAVIGATE TO HOME SCREEN ***
      // DONE: Navigate to home screen
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // *** USER NOT FOUND ***
        Fluttertoast.showToast(msg: 'Email in not registered');
      } else if (e.code == 'wrong-password') {
        // *** WRONG PASSWORD ***
        Fluttertoast.showToast(msg: 'Wrong password');
      }
      return;
    }
  }

  // *** online status ***
  Future<void> updateOnlineStatus(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch
    });
  }

  // *** SIGN out ***
  Future<void> signOut(BuildContext context) async {
    await auth.signOut();
    await googleSignIn.signOut();
    // *** NAVIGATE TO SIGN IN SCREEN ***
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (route) => false);
    }
  }

  // *** user registration data ***
  Future<void> createUser(BuildContext context,
      {Map<String, dynamic> data = const {}, bool lastStep = false}) async {
    if (lastStep) {
      // *** FINAL STEP ***
      // if current user is null, sign in again with credentials
      if (auth.currentUser == null) {
        final creds = (await firestore
                .collection('logindata')
                .doc(_userdata['email'])
                .get())
            .data();
        await auth.signInWithCredential(GoogleAuthProvider.credential(
          accessToken: creds!['accessToken'],
          idToken: creds['idToken'],
        ));
      }
      // set password
      await auth.currentUser!.updatePassword(data['password']);
      // *** SAVE USER DATA ***
      await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set(UserModel.fromJson(_userdata).toJson());
      // *** NAVIGATE TO HOME SCREEN ***
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.routeName, (route) => false);
      }
    } else {
      // *** NOT FINAL STEP ***
      // *** SAVE USER DATA ***
      _userdata.addAll(data);
      if (_userdata.length < 6) {
        // *** NAVIGATE TO NEXT STEP ***
        if (context.mounted) {
          Navigator.pushNamed(context, AcademicInfoScreen.routeName);
        }
      } else {
        // *** NAVIGATE TO LAST STEP ***
        if (context.mounted) {
          Navigator.pushNamed(context, SetPasswordScreen.routeName);
        }
      }
    }
  }
}
