import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_title.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({
    Key? key,
    required this.title,
    required this.report,
  }) : super(key: key);

  final String title;
  final String report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(title: 'Report'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // height: MediaQuery.of(context).size.height * 0.4,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(report),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
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
}
