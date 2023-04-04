import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  final SharedPreferences prefs;

  AuthRepository({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.firestore,
    required this.prefs,
  });

  Future<UserModel> getUser() async {
    final String? user = prefs.getString('user');
    if (user != null) {
      return UserModel.fromJson(jsonDecode(user));
    } else {
      return UserModel();
    }
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
        await firebaseAuth.signInWithCredential(credential);
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
      // TODO: Navigate to sign up screen
    } else {
      // *** EXISTING USER ***
      // *** SAVE USER DATA TO SHARED PREFERENCES ***
      prefs.setString('user', jsonEncode(documents[0].data()));
      // *** NAVIGATE TO HOME SCREEN ***
      // TODO: Navigate to home screen
    }
  }

  // *** SIGN IN WITH EMAIL ***
  Future<void> signInWithEmail(BuildContext context,
      {required String email, required String password}) async {
    try {
      User? user = (await firebaseAuth.signInWithEmailAndPassword(
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
        // TODO: Navigate to sign up screen
        return;
      }
      // *** SAVE USER DATA TO SHARED PREFERENCES ***
      prefs.setString('user', jsonEncode(result.data()));
      // *** NAVIGATE TO HOME SCREEN ***
      // TODO: Navigate to home screen
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
}
