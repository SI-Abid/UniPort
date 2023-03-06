import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uniport/version_1/models/user.dart';

class MessageSender extends User {
  MessageSender({
    super.uid,
    super.email,
    super.photoUrl,
    super.firstName,
    super.lastName,
    super.usertype,
  });
  factory MessageSender.fromJson(Map<String, dynamic> data) {
    return MessageSender(
      uid: data['uid'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      usertype: data['usertype'],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
      'firstName': firstName,
      'lastName': lastName,
      'usertype': usertype,
    };
  }

  Future<User> toUser() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return User.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        return User(
          uid: uid,
          email: email,
          photoUrl: photoUrl,
          firstName: firstName,
          lastName: lastName,
          usertype: usertype,
        );
      }
    });
  }
}
