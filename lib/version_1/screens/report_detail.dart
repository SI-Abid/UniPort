import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_title.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({
    Key? key,
    required this.title,
    required this.report,
    required this.reportId,
  }) : super(key: key);

  final String title;
  final String report;
  final String reportId;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(reportId);
    }
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 24,
        iconTheme: IconThemeData(color: Colors.teal.shade800),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.teal.shade800,
                  ),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.sen(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Divider(
                        color: Colors.teal.shade800,
                        thickness: 0.5,
                      ),
                      Text(
                        report,
                        style: GoogleFonts.sen(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _deleteReport();
                    Navigator.pop(context);
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
                      Colors.red.shade700,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('DELETE',
                        style: GoogleFonts.sen(
                          fontSize: 20,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _deleteReport();
                    Navigator.pop(context);
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
                    child: Text('ACCEPT',
                        style: GoogleFonts.sen(
                          fontSize: 20,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReport() {
    FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
  }
}
