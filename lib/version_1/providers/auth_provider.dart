import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniport/version_1/constants/secret.dart';
import 'package:uniport/version_1/models/user.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
  registrationRequired,
  otpVerificationRequired,
  otpVerificationSuccess,
  otpVerificationError,
  approvalRequired,
}

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final SharedPreferences prefs;
  final EmailAuth emailAuth;

  Status _status = Status.uninitialized;
  final UserModel _user = UserModel();

  Status get status => _status;

  AuthProvider({
    required this.emailAuth,
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.prefs,
    required this.firestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString('uid');
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn && prefs.getString('uid')?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  // *** CREATE NEW USER ***
  // *** STEP 1: SET PERSONAL DATA ***
  // *** STEP 2: SET ACCADEMIC DATA ***
  // *** STEP 3: SET PASSWORD ***
  void setData(
      {String? usertype,
      String? firstName,
      String? lastName,
      String? contact,
      String? department,
      String? teacherId,
      String? initials,
      String? designation,
      bool? isHod,
      String? studentId,
      String? section,
      String? batch}) {
    if (usertype != null) {
      _user.usertype = usertype;
    }
    if (firstName != null) {
      _user.firstName = firstName;
    }
    if (lastName != null) {
      _user.lastName = lastName;
    }
    if (contact != null) {
      _user.contact = contact;
    }
    if (department != null) {
      _user.department = department;
    }
    if (teacherId != null) {
      _user.teacherId = teacherId;
    }
    if (initials != null) {
      _user.initials = initials;
    }
    if (designation != null) {
      _user.designation = designation;
    }
    if (isHod != null) {
      _user.isHod = isHod;
    }
    if (studentId != null) {
      _user.studentId = studentId;
    }
    if (section != null) {
      _user.section = section;
    }
    if (batch != null) {
      _user.batch = batch;
    }
  }

  // *** LOGIN WITH GOOGLE ***
  Future<bool> handleGoogleSignIn() async {
    _status = Status.authenticating;
    notifyListeners();

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        // *** SAVE LOGIN CREDENTIALS ***
        firestore.collection('logindata').doc(firebaseUser.email).set({
          'idToken': googleAuth.idToken,
          'accessToken': googleAuth.accessToken,
        });
        final QuerySnapshot result = await firestore
            .collection('users')
            .where('uid', isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.isEmpty) {
          // *** NEW USER ***
          _user.uid = firebaseUser.uid;
          _user.email = firebaseUser.email;
          _user.photoUrl = firebaseUser.photoURL;
          _status = Status.registrationRequired;
          notifyListeners();
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          UserModel user = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          // Write data to local
          await prefs.setString('user', jsonEncode(user.toJson()));
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  // *** LOGIN WITH EMAIL AND PASSWORD ***
  Future<bool> handleEmailSignIn(String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();

    User? firebaseUser = (await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (firebaseUser != null) {
      final DocumentSnapshot result =
          await firestore.collection('users').doc(firebaseUser.uid).get();
      if (result.exists) {
        UserModel user =
            UserModel.fromJson(result.data() as Map<String, dynamic>);
        // Write data to local
        await prefs.setString('user', jsonEncode(user.toJson()));

        if (user.approved == false) {
          _status = Status.approvalRequired;
          notifyListeners();
          return true;
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      }
      _status = Status.authenticateError;
      notifyListeners();
      return false;
    }
    _status = Status.authenticateError;
    notifyListeners();
    return false;
  }

  // *** NEW USER REGISTRATION ***
  Future<void> handleRegistration(String password) async {
    _status = Status.authenticating;
    notifyListeners();

    User? firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser != null) {
      firestore.collection('users').doc(_user.uid).set(_user.toJson());

      // Write data to local
      prefs.setString('user', jsonEncode(_user.toJson()));
      // *** SETTING PASSWORD ***
      if (firebaseAuth.currentUser != null) {
        await firebaseAuth.currentUser!.updatePassword(password);
        await firebaseAuth.currentUser!.reload();
        await firebaseAuth.currentUser!.sendEmailVerification();
        _status = Status.authenticated;
        notifyListeners();
        return;
      }
      final googleUser = googleSignIn.currentUser;
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final firebaseUser =
            (await firebaseAuth.signInWithCredential(credential)).user;
        if (firebaseUser != null) {
          await firebaseUser.updatePassword(password);
          await firebaseUser.reload();
          await firebaseUser.sendEmailVerification();
          _status = Status.authenticated;
          notifyListeners();
          return;
        }
      }
      // *** ELSE LOAD FROM FIRESTORE ***
      final result =
          await firestore.collection('logindata').doc(_user.email).get();
      String idToken = result.data()!['idToken'];
      String accessToken = result.data()!['accessToken'];
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        await firebaseUser.updatePassword(password);
        await firebaseUser.reload();
        await firebaseUser.sendEmailVerification();
        _status = Status.authenticated;
        notifyListeners();
        return;
      }
      _status = Status.authenticateError;
      notifyListeners();
    } else {
      _status = Status.authenticateError;
      notifyListeners();
    }
  }

  // *** PASSWORD RESET ***
  Future<void> handlePasswordReset(String email) async {
    _status = Status.authenticating;
    notifyListeners();
    // *** CHECK IF EMAIL EXISTS ***
    final QuerySnapshot result = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (result.docs.first.exists == false) {
      // *** EMAIL DOES NOT EXIST ***
      _status = Status.otpVerificationError;
      notifyListeners();
      return;
    }
    await emailAuth.config({
      'server': Secret.server,
      'serverKey': Secret.serverKey,
    });
    bool status = await emailAuth.sendOtp(recipientMail: email);
    if (status) {
      _status = Status.otpVerificationRequired;
      notifyListeners();
    } else {
      _status = Status.otpVerificationError;
      notifyListeners();
    }
  }

  // *** OTP VERIFICATION ***
  void handleOtpVerification(String email, String otp) {
    _status = Status.authenticating;
    notifyListeners();
    bool status = emailAuth.validateOtp(recipientMail: email, userOtp: otp);
    if (status) {
      _status = Status.otpVerificationSuccess;
      notifyListeners();
    } else {
      _status = Status.otpVerificationError;
      notifyListeners();
    }
  }

  // *** PASSWORD RESET COMPLETION ***
  Future<void> handlePasswordResetComplete(
      String email, String password) async {
    _status = Status.authenticating;
    notifyListeners();
    // fetch login creds
    final DocumentSnapshot result =
        await firestore.collection('logindata').doc(email).get();
    Map<String, dynamic> data = result.data() as Map<String, dynamic>;
    // sign in with creds
    final AuthCredential creds = GoogleAuthProvider.credential(
        accessToken: data['accessToken'], idToken: data['idToken']);
    await firebaseAuth.signInWithCredential(creds);
    User? user = firebaseAuth.currentUser;
    // change password if signed in
    if (user != null) {
      await user.updatePassword(password);
      _status = Status.uninitialized;
      notifyListeners();
    } else {
      _status = Status.authenticateError;
      notifyListeners();
    }
  }

  void handleException() {
    _status = Status.authenticateException;
    notifyListeners();
  }

  // *** LOGOUT ***
  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }
}