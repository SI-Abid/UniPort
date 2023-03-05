import 'package:flutter/material.dart';

import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class StudentInfoBody extends StatefulWidget {
  const StudentInfoBody({super.key});

  @override
  State<StudentInfoBody> createState() => _StudentInfoBodyState();
}

class _StudentInfoBodyState extends State<StudentInfoBody> {
  final sIdController = TextEditingController();

  final sectionController = TextEditingController();

  final batchController = TextEditingController();

  final deptController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 380,
      // blur effect on the container
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Should be Student ID
              CustomTextField(
                controller: sIdController,
                hintText: 'Student ID',
                formValidator: studentIdValidator,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              // Should be Section
              CustomTextField(
                controller: sectionController,
                hintText: 'Section',
                formValidator: sectionValidator,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 5),
              // Should be Batch
              CustomTextField(
                controller: batchController,
                hintText: 'Batch',
                formValidator: batchValidator,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              // Should be Department
              CustomTextField(
                controller: deptController,
                hintText: 'Department',
                formValidator: departmentValidator,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 10),
              // Next Button
              ActionButton(
                text: 'NEXT',
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  String sid = sIdController.text.trim();
                  String section = sectionController.text.trim();
                  String batch = batchController.text.trim();
                  String dept = deptController.text.trim().toUpperCase();
                  formKey.currentState!.save();
                  loggedInUser.usertype = 'student';
                  loggedInUser.studentId = sid;
                  loggedInUser.section = section;
                  loggedInUser.batch = batch;
                  loggedInUser.department = dept;
                  // print('Student page: $loggedInUser');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SetPasswordRegScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
