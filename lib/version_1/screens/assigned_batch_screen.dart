import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class AssignedBatchScreen extends StatefulWidget {
  const AssignedBatchScreen({super.key});

  @override
  State<AssignedBatchScreen> createState() => _AssignedBatchScreenState();
}

class _AssignedBatchScreenState extends State<AssignedBatchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Assigned Batch'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch List',
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
                  .where('members', arrayContains: loggedInUser.uid)
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
                                builder: (context) => GroupChatScreen(
                                  groupId: groupIds[index],
                                  title:
                                      '${groupsList[index]['batch']} ${groupsList[index]['sections'].join('+')}',
                                ),
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
                                'Advising ${groupsList[index]['batch']} ${groupsList[index]['sections'].join('+')}',
                                style: GoogleFonts.sen(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              subtitle: Text(
                                '${groupsList[index]['lastMessage']['content']}',
                                softWrap: true,
                                maxLines: 1,
                                style: GoogleFonts.sen(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey.shade800,
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
