import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/providers/user_provider.dart';
import 'package:uniport/version_1/screens/set_password_reg.dart';

import '../models/user.dart';
import '../widgets/academic_info_tapbar.dart';
import '../widgets/color_constant.dart';
import '../widgets/student_info_body.dart';
import '../widgets/teacher_info_body.dart';

class AcademicInfoScreen extends ConsumerStatefulWidget {
  static const String routeName = '/academic-info';
  const AcademicInfoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AcademicInfoScreen> createState() => _AcademicInfoScreenState();
}

class _AcademicInfoScreenState extends ConsumerState<AcademicInfoScreen> {
  String userType = "student";

  @override
  void initState() {
    super.initState();
  }

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
