import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/academic_info_tapbar.dart';
import '../widgets/color_constant.dart';
import '../widgets/student_info_body.dart';
import '../widgets/teacher_info_body.dart';

class AcademicInfoRegScreen extends StatefulWidget {
  const AcademicInfoRegScreen({Key? key}) : super(key: key);

  @override
  State<AcademicInfoRegScreen> createState() => _AcademicInfoRegScreenState();
}

class _AcademicInfoRegScreenState extends State<AcademicInfoRegScreen> {
  String userType = "student";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorConstant.teal700),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: <Widget>[
                const AcademicInfoHeaderText(),
                const SizedBox(height: 40),
                AcademicInfoTapbar(
                  onTabChanged: (value) => setState(() => userType = value),
                ),
                const SizedBox(height: 40),
                userType == "student"
                    ? const StudentInfoBody()
                    : const TeacherInfoBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AcademicInfoHeaderText extends StatelessWidget {
  const AcademicInfoHeaderText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Academic Information",
        style: GoogleFonts.sen(
          letterSpacing: 0.5,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: ColorConstant.teal700,
        ),
      ),
    );
  }
}
