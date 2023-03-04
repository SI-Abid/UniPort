import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key}) : super(key: key);

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  @override
  Widget build(BuildContext context) {
    // print(loggedInUser);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppTitle(title: 'Group Chats'),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advisor Group',
              style: GoogleFonts.sen(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.teal.shade800,
              ),
            ),
            Divider(
              color: Colors.teal.shade800,
              thickness: 0.5,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('advisor groups')
                  .where('batch', isEqualTo: loggedInUser.batch ?? '53')
                  .where('sections', arrayContains: loggedInUser.section ?? 'A')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                  final List groupsList = docs.map((e) => e.data()).toList();
                  final List groupIds = docs.map((e) => e.id).toList();
                  return Expanded(
                    child: ListView.builder(
                      itemCount: groupsList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    GroupChatScreen(groupId: groupIds[index]),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade800,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: Text(
                                    '${groupsList[index]['batch']}',
                                    style: GoogleFonts.sen(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                'SECTION',
                                style: GoogleFonts.sen(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              subtitle: Text(
                                '${groupsList[index]['sections'].join(' ')}',
                                style: GoogleFonts.sen(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
