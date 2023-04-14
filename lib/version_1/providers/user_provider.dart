import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';

final userProvider = StateNotifierProvider<UserProvider, UserModel>((ref) {
  return UserProvider(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(scopes: ['email']));
});

class UserProvider extends StateNotifier<UserModel> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  UserProvider(
      {required this.firestore, required this.auth, required this.googleSignIn})
      : super(UserModel());

  Future<void> logout() async {
    state.status = Status.loading;
    await googleSignIn.signOut();
    updateOnlineStatus(false);
    state = UserModel();
    state.status = Status.loggedOut;
  }

  Future<void> loginWithEmail(String email, String password) async {
    state.status = Status.loading;
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
        return;
      }
      // *** NAVIGATE TO HOME SCREEN ***
      // DONE: Navigate to home screen
      state = UserModel.fromJson(result.data()! as Map<String, dynamic>);
      state.status = Status.loggedIn;
      return;
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

  Future<void> loginWithGoogle() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // *** USER CANCELLED SIGN IN ***
      return;
    }
    state.status = Status.loading;
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
        .where('uid', isEqualTo: user.uid)
        .get();
    List<DocumentSnapshot> documents = result.docs;
    if (documents.isEmpty) {
      // *** NEW USER ***
      // *** NAVIGATE TO SIGN UP SCREEN ***
      // DONE: Navigate to sign up screen
      state.status = Status.newUser;
      return;
    }
    // *** EXISTING USER ***
    // *** NAVIGATE TO HOME SCREEN ***
    state = UserModel.fromJson(documents[0].data()! as Map<String, dynamic>);
    state.status = Status.loggedIn;
    return;
  }

  Future<void> registerUser({required String password}) async {
    state.status = Status.loading;
    try {
      var user = auth.currentUser;
      if (user != null) {
        await user.updatePassword(password);
        firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .set(state.toJson());
      }
      if (googleSignIn.currentUser != null) {
        final googleAuth = await googleSignIn.currentUser?.authentication;
        if (googleAuth == null) {
          throw Exception('registration failed');
        }
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await auth.signInWithCredential(credential);
        final User? user = authResult.user;
        if (user == null) {
          throw Exception('registration failed');
        }
        await user.updatePassword(password);
        firestore.collection('users').doc(user.uid).set(state.toJson());
        state.status = Status.registrationDone;
        return;
      }
      final creds =
          await firestore.collection('logindata').doc(state.email).get();
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: creds['accessToken'],
        idToken: creds['idToken'],
      );
      final UserCredential authResult =
          await auth.signInWithCredential(credential);
      user = authResult.user;
      if (user == null) {
        throw Exception('registration failed');
      }
      await user.updatePassword(password);
      firestore.collection('users').doc(user.uid).set(state.toJson());
      state.status = Status.registrationDone;
      return;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registration failed');
      return;
    }
  }

  void setPersonalInfo(UserModel tmpUser) async {
    state.copyWith(tmpUser);
    state.status = Status.personalInfoDone;
    return;
  }

  void setAcademicInfo(UserModel tmpUser) async {
    state.copyWith(tmpUser);
    state.status = Status.academicInfoDone;
    return;
  }

  void setIsHod(bool isHod) {
    state.isHod = isHod;
    return;
  }

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> users = [];
    await firestore
        .collection('users')
        .where('approved', isEqualTo: true)
        .where('uid', isNotEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      for (var element in value.docs) {
        users.add(UserModel.fromJson(element.data()));
      }
    });
    return users;
  }

  // *** online status ***
  Future<void> updateOnlineStatus(bool isOnline) async {
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().millisecondsSinceEpoch
    });
  }
}
