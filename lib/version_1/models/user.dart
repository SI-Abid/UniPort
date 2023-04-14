enum Status {
  loading,
  loggedIn,
  loggedOut,
  newUser,
  notApproved,
  personalInfoDone,
  academicInfoDone,
  registrationDone,
}

class UserModel {
  Status status = Status.loggedOut;
  // common data
  String? usertype;
  bool? approved;
  String? email;
  String uid;
  String? firstName;
  String? lastName;
  String? contact;
  String? department;
  String? photoUrl;
  String? pushToken;
  // if teacher
  String? teacherId;
  String? initials;
  String? designation;
  bool? isHod;
  // if student
  String? studentId;
  String? section;
  String? batch;
  UserModel({
    this.uid = '',
    this.usertype = 'student',
    this.approved = false,
    this.email,
    this.firstName,
    this.lastName,
    this.contact,
    this.department,
    this.teacherId,
    this.initials,
    this.designation,
    this.studentId,
    this.section,
    this.batch,
    this.photoUrl,
    this.pushToken,
    this.isHod = false, // head of department (hod)
  });

  void copyWith(UserModel user) {
    usertype = user.usertype ?? usertype;
    approved = user.approved ?? approved;
    email = user.email ?? email;
    uid = user.uid;
    firstName = user.firstName ?? firstName;
    lastName = user.lastName ?? lastName;
    contact = user.contact ?? contact;
    department = user.department ?? department;
    teacherId = user.teacherId ?? teacherId;
    initials = user.initials ?? initials;
    designation = user.designation ?? designation;
    studentId = user.studentId ?? studentId;
    section = user.section ?? section;
    batch = user.batch ?? batch;
    photoUrl = user.photoUrl ?? photoUrl;
    isHod = user.isHod ?? isHod;
    pushToken = user.pushToken ?? pushToken;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      usertype: json['usertype'],
      approved: json['approved'],
      email: json['email'],
      uid: json['uid'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      contact: json['contact'],
      department: json['department'],
      teacherId: json['teacherId'],
      initials: json['initials'],
      designation: json['designation'],
      studentId: json['studentId'],
      section: json['section'],
      batch: json['batch'],
      photoUrl: json['photoUrl'],
      pushToken: json['pushToken'],
      isHod: json['isHod'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> object = {
      'usertype': usertype,
      'approved': approved,
      'email': email,
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'contact': contact,
      'department': department,
      'photoUrl': photoUrl,
      'pushToken': pushToken,
    };
    if (usertype == 'student') {
      object['studentId'] = studentId;
      object['section'] = section;
      object['batch'] = batch;
    }
    if (usertype == 'teacher') {
      object['teacherId'] = teacherId;
      object['initials'] = initials;
      object['designation'] = designation;
      object['isHod'] = isHod;
    }
    return object;
  }

  String get name => '${firstName ?? 'A'} ${lastName ?? '?'}';

  @override
  String toString() {
    return 'User{usertype: $usertype, approved: $approved, email: $email, uid: $uid, firstName: $firstName, lastName: $lastName, contact: $contact, department: $department, teacherId: $teacherId, initials: $initials, designation: $designation, studentId: $studentId, section: $section, batch: $batch, photoUrl: $photoUrl, isHod: $isHod, pushToken: $pushToken}';
  }
}
