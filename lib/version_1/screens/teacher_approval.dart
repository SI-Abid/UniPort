import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class TeacherApproval extends StatefulWidget {
  static const String routeName = '/teacher-approval';
  const TeacherApproval({super.key});

  @override
  State<TeacherApproval> createState() => _TeacherApprovalState();
}

class _TeacherApprovalState extends State<TeacherApproval> {
  final List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        backgroundColor: Colors.transparent,
        title: const AppTitle(title: 'Teacher Approval'),
        elevation: 0,
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('approved', isEqualTo: false)
                .where('usertype', isEqualTo: 'teacher')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return const LoadingScreen();
              }
              final List<UserModel> users = snapshot.data!.docs
                  .map((e) => UserModel.fromJson(e.data()))
                  .toList();
              if (users.isEmpty) {
                return Center(
                    child: Text(
                  'No pending teachers',
                  style: TextStyle(
                    color: Colors.teal.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ));
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return PendingTeacherTile(
                    user: user,
                    selected: selected,
                    trigger: () => setState(() {}),
                  );
                },
              );
            },
          ),
          if (selected.isNotEmpty)
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                            const Size(250, 50),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.teal.shade800),
                        ),
                        onPressed: () async {
                          for (final id in selected) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(id)
                                .update({'approved': true});
                          }
                          setState(() {
                            selected.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Approve ${selected.length} teacher(s)',
                            style: GoogleFonts.sen(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/teacherApproval');
                        },
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                            const Size(250, 50),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                  color: Colors.teal.shade800, width: 2),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            Colors.white,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('Cancel',
                              style: GoogleFonts.sen(
                                fontSize: 20,
                                color: Colors.red,
                              )),
                        )),
                  ]),
            )
        ],
      ),
    );
  }
}
