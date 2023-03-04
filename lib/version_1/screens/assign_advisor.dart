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
      // batchInfoList.sort((a, b) => a['batch'].compareTo(b['batch']));
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
              automaticallyImplyLeading: false,
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
                      child: Column(
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
                            decoration: InputDecoration(
                              constraints: const BoxConstraints(minHeight: 65),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 255, 69, 69),
                                  width: 1.5,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 10, 10, 10),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedTeacher = value;
                              });
                            },
                          ),
                        ],
                      ),
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
                            decoration: InputDecoration(
                              constraints: const BoxConstraints(minHeight: 65),
                              errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 255, 69, 69),
                                  width: 1.5,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 10, 10, 10),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(255, 24, 143, 121),
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
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
                        if (selectedSection.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select at least one section',
                                style: GoogleFonts.sen(
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color.fromARGB(255, 255, 69, 69),
                                ),
                              ),
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 69, 69)
                                      .withOpacity(0.2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } else {
                          Message firstMessage = Message(
                            sender: selectedTeacher!.uid,
                            message:
                                'Hello, I am ${selectedTeacher!.name}, your advisor. You can ask me anything related to your academics.',
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                          );
                          FirebaseFirestore.instance
                              .collection('advisor groups')
                              .doc('${selectedTeacher!.uid}$selectedBatch')
                              .set({
                            'users': [selectedTeacher!.toJson()],
                            'batch': selectedBatch,
                            'sections': selectedSection,
                            'chats': [firstMessage.toJson()],
                          }, SetOptions(merge: true)).then(
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
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
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
