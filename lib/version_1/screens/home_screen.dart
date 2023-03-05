import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.debug = false});
  final bool debug;
  @override
  Widget build(BuildContext context) {
    final double ratio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'UNIPORT'),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
        actions: [
          const NotificationButton(),
          GestureDetector(
            onTap: () {
              signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Card(
              elevation: 2,
              shape: const CircleBorder(),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.teal.shade800,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        crossAxisCount: 2,
        childAspectRatio: ratio < 2 ? 0.8 : 0.85,
        children: [
          // NOTE: for all users
          const CustomCard(
              iconPath: 'assets/icon/chat_any.svg',
              title: 'CHAT',
              subtitle: 'ONE-ONE',
              actionName: 'MESSAGE',
              routeName: '/chat'),
          // NOTE: for students
          if (loggedInUser.usertype == 'student' || debug)
            const CustomCard(
                iconPath: 'assets/icon/anonymous.svg',
                title: 'CHAT',
                subtitle: 'ANONYMOUS',
                actionName: 'REPORT',
                routeName: '/studentReport'),
          if (loggedInUser.usertype == 'student' || debug)
            const CustomCard(
                iconPath: 'assets/icon/group_chat.svg',
                title: 'GROUP CHAT',
                subtitle: 'ADVISOR & COURSES',
                actionName: 'MESSAGE',
                routeName: '/groupChat'),
          // NOTE: for teachers
          if (loggedInUser.usertype == 'teacher' || debug)
            const CustomCard(
                iconPath: 'assets/icon/assigned_batch.svg',
                title: 'ASSIGNED BATCH',
                subtitle: 'GROUP CHAT',
                actionName: 'MESSAGE',
                routeName: '/assignedBatch'),
          if (loggedInUser.usertype == 'teacher' || debug)
            const CustomCard(
                iconPath: 'assets/icon/student.svg',
                title: 'STUDENTS',
                subtitle: 'PENDING',
                actionName: 'APPROVE',
                routeName: '/studentApproval'),
          // NOTE: for HODs
          if (loggedInUser.isHod == true || debug)
            const CustomCard(
                iconPath: 'assets/icon/teacher.svg',
                title: 'TEACHERS',
                subtitle: 'PENDING',
                actionName: 'APPROVE',
                routeName: '/teacherApproval'),
          if (loggedInUser.isHod == true || debug)
            CustomCard(
              iconPath: 'assets/icon/batch_advisor.svg',
              title: 'ADVISOR',
              subtitle: 'BATCH',
              actionName: 'ASSIGN',
              routeName: '/assignAdvisor',
              action: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .where('usertype', isEqualTo: 'teacher')
                              .where('approved', isEqualTo: true)
                              .get(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              final List<User> teacherList = [];
                              for (final doc in snapshot.data!.docs) {
                                teacherList.add(User.fromJson(
                                    doc.data() as Map<String, dynamic>));
                              }
                              print(teacherList);
                              return AssignAdvisor(teacherList: teacherList);
                            }
                            return const LoadingScreen();
                          });
                    },
                  ),
                );
              },
            ),
          if (loggedInUser.isHod == true || debug)
            const CustomCard(
                iconPath: 'assets/icon/anonymous.svg',
                title: 'REPORTS',
                subtitle: 'ANONYMOUS',
                actionName: 'VIEW',
                routeName: '/reportView'),
        ],
      ),
      backgroundColor:
          debug ? Colors.deepPurple.shade100 : const Color(0xfff5f5f5),
    );
  }
}
