import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widgets.dart';
import '../screens/screens.dart';

class ReportViewScreen extends StatelessWidget {
  static const String routeName = '/report-view';
  const ReportViewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              final reports = snapshot.data!.docs;
              if (reports.isEmpty) {
                return Text('No reports yet',
                    style: TextStyle(
                      color: Colors.teal.shade900,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ));
              }
              final reportIds = reports.map((e) => e.id).toList();
              reports.sort((a, b) {
                final aTime = a['timestamp'] as int;
                final bTime = b['timestamp'] as int;
                return bTime.compareTo(aTime);
              });
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ReportDetailsScreen(
                          reportId: reportIds[index],
                          title: report['title'],
                          report: report['report'],
                        );
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  report['title'],
                                  softWrap: true,
                                  style: GoogleFonts.sen(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reported on: ${DateTime.fromMillisecondsSinceEpoch(report['timestamp'] as int).toString().substring(0, 10)}',
                                  style: GoogleFonts.sen(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Report'),
                                    content: const Text(
                                        'Are you sure you want to delete this report?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color:
                                                      Colors.teal.shade800))),
                                      TextButton(
                                        onPressed: () {
                                          _resolveReport(reportIds[index]);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Accept Report'),
                                    content: const Text(
                                        'Are you sure you want to accept this report?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color:
                                                      Colors.teal.shade800))),
                                      TextButton(
                                        onPressed: () {
                                          _resolveReport(reportIds[index]);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Accept',
                                            style:
                                                TextStyle(color: Colors.green)
                                            // style: TextStyle(color: Colors.teal.shade800),
                                            ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade800,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child:
                                  const Icon(Icons.check, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const LoadingScreen();
          },
        ),
      ),
    );
  }

  void _resolveReport(String reportId) {
    FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
  }
}

class StudentReportScreen extends StatelessWidget {
  static const String routeName = '/student-report';
  
  StudentReportScreen({super.key});

  final titleController = TextEditingController();
  final reportController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Report'),
        // centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xfff5f5f5),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Write Report',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.sen(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade800,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                child: Divider(
                  color: Colors.teal.shade800,
                  thickness: 0.5,
                ),
              ),
              Container(
                height: 70,
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Report Title',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: reportController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Report',
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      borderSide: BorderSide(color: Colors.teal.shade800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    FirebaseFirestore.instance.collection('reports').add({
                      'title': titleController.text,
                      'report': reportController.text,
                      'timestamp': DateTime.now().millisecondsSinceEpoch,
                    });
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      const Size(250, 50),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      Colors.teal.shade800,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('SEND',
                        style: GoogleFonts.sen(
                          fontSize: 20,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
