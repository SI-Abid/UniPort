class User {
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
  // if teacher
  String? teacherId;
  String? initials;
  String? designation;
  bool? isHod;
  // if student
  String? studentId;
  String? section;
  String? batch;
  User({
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
    this.isHod = false, // head of department (hod)
  });
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      isHod: json['isHod'],
    );
  }
  String get name => '${firstName ?? 'A'} ${lastName ?? '?'}';

  @override
  String toString() {
    return 'User{usertype: $usertype, approved: $approved, email: $email, uid: $uid, firstName: $firstName, lastName: $lastName, contact: $contact, department: $department, teacherId: $teacherId, initials: $initials, designation: $designation, studentId: $studentId, section: $section, batch: $batch, photoUrl: $photoUrl, isHod: $isHod}';
  }
}
