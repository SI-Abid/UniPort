import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              const Icon(Icons.arrow_back),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: GoogleFonts.sen(
                  fontSize: 16,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: GoogleFonts.sen(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          )
        ],
        backgroundColor: const Color(0xfff5f5f5),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  border: InputBorder.none,
                  hintText: 'Search by Id or Name',
                  hintStyle: GoogleFonts.sen(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  suffixIcon: const Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // listview
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: GoogleFonts.sen(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Last message',
                              style: GoogleFonts.sen(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xfff5f5f5),
    );
  }
}
