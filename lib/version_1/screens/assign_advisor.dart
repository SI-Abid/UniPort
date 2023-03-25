import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class AssignAdvisor extends StatefulWidget {
  const AssignAdvisor({super.key, required this.teacherList});
  final List<User> teacherList;
  @override
  State<AssignAdvisor> createState() => _AssignAdvisorState();
}

class _AssignAdvisorState extends State<AssignAdvisor> {
  late List<Map<String, dynamic>> batchInfoList;
  bool isLoading = true;
  List<String> selectedSection = [];
  String? selectedBatch;
  int selectedBatchIndex = 0;
  User? selectedTeacher;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('batchInfo').get().then((value) {
      batchInfoList = value.docs.map((e) => e.data()).toList();
      // print(batchInfoList);
      batchInfoList.sort((a, b) => a['batch'].compareTo(b['batch']));
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              leadingWidth: 24,
              iconTheme: IconThemeData(color: Colors.teal.shade800),
              title: const AppTitle(title: 'Advisor Assign'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            backgroundColor: const Color(0xfff5f5f5),
            body: Center(
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: _getAdvisorForm(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Batch',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 24, 143, 121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField(
                            hint: Text(
                              'No Batch Assigned',
                              style: GoogleFonts.sen(
                                letterSpacing: 0.5,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: const Color.fromARGB(255, 24, 143, 121),
                              ),
                            ),
                            items: batchInfoList.map((batchInfo) {
                              return DropdownMenuItem(
                                value: batchInfo['batch'],
                                child: Text(
                                  batchInfo['batch'],
                                  style: GoogleFonts.sen(
                                    letterSpacing: 0.5,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color:
                                        const Color.fromARGB(255, 24, 143, 121),
                                  ),
                                ),
                              );
                            }).toList(),
                            style: GoogleFonts.sen(
                              letterSpacing: 0.5,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 24, 143, 121),
                            ),
                            decoration: _getDecoration(),
                            onChanged: (value) {
                              setState(() {
                                if (value != selectedBatch) {
                                  selectedSection.clear();
                                }
                                selectedBatchIndex = batchInfoList.indexWhere(
                                    (element) => element['batch'] == value);
                                selectedBatch = value as String;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // filter chips for section with buttons
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sections',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Color.fromARGB(255, 24, 143, 121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: getSectionChips(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ActionButton(
                      text: 'ASSIGN',
                      onPressed: () {
                        if (selectedTeacher == null) {
                          Fluttertoast.showToast(
                            msg: 'Please select a teacher',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else if (selectedBatch == null) {
                          Fluttertoast.showToast(
                            msg: 'Please select a batch',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else if (selectedSection.isEmpty) {
                          Fluttertoast.showToast(
                            msg: 'Please select at least one section',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          selectedSection.sort();
                          Message firstMessage = Message(
                            sender: selectedTeacher!.uid,
                            content:
                                'Hello, I am ${selectedTeacher!.name}, your advisor. You can ask me anything related to your academics.',
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            type: MessageType.text,
                          );
                          _handleAdvisorAssign(context, firstMessage);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> _handleAdvisorAssign(
      BuildContext context, Message firstMessage) {
    final advisorGroupId = '${selectedTeacher!.uid}$selectedBatch';
    // if group already exists, warn the user
    // else create a new group
    final docRef = FirebaseFirestore.instance
        .collection('advisor groups')
        .doc(advisorGroupId);
    return docRef.get().then(
      (doc) {
        if (doc.exists) {
          final String assignedSections = doc['sections'].join(', ');
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Warning'),
              content: Text(
                'This advisor is already assigned to the following sections: $assignedSections of batch $selectedBatch. Re-assigning will delete the existing group. Do you want to continue?',
                style: GoogleFonts.sen(
                  letterSpacing: 0.5,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 24, 143, 121),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Continue'),
                  onPressed: () {
                    Navigator.pop(context);
                    docRef.set({
                      'batch': selectedBatch,
                      'members': FieldValue.arrayUnion([selectedTeacher!.uid]),
                      'sections': FieldValue.arrayUnion(selectedSection),
                      'lastMessage': firstMessage.toJson(),
                    }).then((value) {
                      return docRef
                          .collection('messages')
                          .doc(firstMessage.createdAt.toString())
                          .set(firstMessage.toJson());
                    }).then(
                      (value) {
                        Fluttertoast.showToast(
                          msg: 'Advisor assigned successfully',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green.withOpacity(0.8),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        // Navigator.pop(context);
                        // clear the selected values
                        setState(() {
                          selectedSection.clear();
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          docRef.set({
            'batch': selectedBatch,
            'members': [selectedTeacher!.uid],
            'sections': selectedSection,
            'lastMessage': firstMessage.toJson(),
          }).then((value) {
            return docRef
                .collection('messages')
                .doc(firstMessage.createdAt.toString())
                .set(firstMessage.toJson());
          }).then(
            (value) {
              Fluttertoast.showToast(
                msg: 'Advisor assigned successfully',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green.withOpacity(0.8),
                textColor: Colors.white,
                fontSize: 16.0,
              );
              // Navigator.pop(context);
              // clear the selected values
              setState(() {
                selectedSection.clear();
              });
            },
          );
        }
      },
    );
  }

  InputDecoration _getDecoration() {
    return InputDecoration(
      constraints: const BoxConstraints(minHeight: 65),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 255, 69, 69),
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      errorStyle: GoogleFonts.sen(
        letterSpacing: 0.5,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color.fromARGB(255, 255, 69, 69),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 255, 69, 69),
          width: 1.5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 24, 143, 121),
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 24, 143, 121),
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Color.fromARGB(255, 24, 143, 121),
          width: 2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }

  Column _getAdvisorForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Teacher',
          style: TextStyle(
            letterSpacing: 0.5,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color.fromARGB(255, 24, 143, 121),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField(
          hint: Text(
            'No Teacher Assigned',
            style: GoogleFonts.sen(
              letterSpacing: 0.5,
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: const Color.fromARGB(255, 24, 143, 121),
            ),
          ),
          items: widget.teacherList.map((teacher) {
            return DropdownMenuItem(
              value: teacher,
              child: Text(
                '${teacher.initials}, ${teacher.name}',
                style: GoogleFonts.sen(
                  letterSpacing: 0.5,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: const Color.fromARGB(255, 24, 143, 121),
                ),
              ),
            );
          }).toList(),
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 24, 143, 121),
          ),
          decoration: InputDecoration(
            constraints: const BoxConstraints(minHeight: 65),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 69, 69),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            errorStyle: GoogleFonts.sen(
              letterSpacing: 0.5,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 255, 69, 69),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 69, 69),
                width: 1.5,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 24, 143, 121),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 24, 143, 121),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 24, 143, 121),
                width: 2,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedTeacher = value;
            });
          },
        ),
      ],
    );
  }

  List<Widget> getSectionChips() {
    List<Widget> sectionChips = [];
    for (int i = 0;
        i < batchInfoList[selectedBatchIndex]['sections'].length;
        i++) {
      sectionChips.add(
        FilterChip(
          label: Text(
            batchInfoList[selectedBatchIndex]['sections'][i],
            style: GoogleFonts.sen(
              letterSpacing: 0.5,
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: const Color.fromARGB(255, 24, 143, 121),
            ),
          ),
          selected: selectedSection
              .contains(batchInfoList[selectedBatchIndex]['sections'][i]),
          onSelected: (value) {
            setState(
              () {
                if (value) {
                  selectedSection
                      .add(batchInfoList[selectedBatchIndex]['sections'][i]);
                } else {
                  selectedSection
                      .remove(batchInfoList[selectedBatchIndex]['sections'][i]);
                }
              },
            );
          },
          selectedColor:
              const Color.fromARGB(255, 24, 143, 121).withOpacity(0.2),
          checkmarkColor: const Color.fromARGB(255, 24, 143, 121),
          backgroundColor:
              const Color.fromARGB(255, 24, 143, 121).withOpacity(0.2),
        ),
      );
    }
    return sectionChips;
  }
}
