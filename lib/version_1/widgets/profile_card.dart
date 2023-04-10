import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';
import 'avatar.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.messageSender,
  });

  final UserModel messageSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: Container(
        height: 440,
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.blueGrey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(user: messageSender, size: 80),
            const SizedBox(
              height: 20,
            ),
            Text(
              messageSender.name,
              style: GoogleFonts.sen(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              messageSender.email ?? '',
              style: GoogleFonts.sen(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Contact: ${messageSender.contact}',
              style: GoogleFonts.sen(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (messageSender.usertype == 'student')
              Column(
                children: [
                  Text(
                    'ID: ${messageSender.studentId}',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Batch: ${messageSender.batch} ',
                        style: GoogleFonts.sen(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        ' (${messageSender.section})',
                        style: GoogleFonts.sen(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    'Initials: ${messageSender.initials}',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    messageSender.designation ?? '',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (messageSender.isHod != null && messageSender.isHod!)
                  Text(
                    'Head of Department, ',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  )
                else
                  Text(
                    'Department of ',
                    style: GoogleFonts.sen(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                Text(
                  messageSender.department ?? '',
                  style: GoogleFonts.sen(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
