import 'package:flutter/material.dart';

import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class TeacherInfoBody extends StatefulWidget {
  const TeacherInfoBody({super.key});

  @override
  State<TeacherInfoBody> createState() => _TeacherInfoBodyState();
}

class _TeacherInfoBodyState extends State<TeacherInfoBody> {
  final tIdController = TextEditingController();

  final intialController = TextEditingController();

  final designationController = TextEditingController();

  final deptController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final checkbox = CustomCheckBox(text: 'Head of Department');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.88,
      height: 430,
      // blur effect on the container
      //testing git push
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
              // Should be Teacher ID
              CustomTextField(
                controller: tIdController,
                hintText: 'Teacher ID',
                formValidator: teacherIdValidator,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 5),
              // Should be Initials
              CustomTextField(
                controller: intialController,
                hintText: 'Initial',
                formValidator: initialsValidator,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 5),
              // Should be Designation
              CustomTextField(
                controller: designationController,
                hintText: 'Designation',
                formValidator: designationValidator,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 5),
              // Should be Department
              CustomTextField(
                controller: deptController,
                hintText: 'Department',
                formValidator: departmentValidator,
                textCapitalization: TextCapitalization.characters,
              ),
              // const SizedBox(height: 5),
              // Should be Department
              checkbox,
              const SizedBox(height: 5),
              // Next Button
              ActionButton(
                text: 'NEXT',
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  formKey.currentState!.save();
                  String tid = tIdController.text.trim();
                  String initial = intialController.text.trim().toUpperCase();
                  String designation = designationController.text.trim();
                  String dept = deptController.text.trim();
                  loggedInUser.usertype = 'teacher';
                  loggedInUser.teacherId = tid;
                  loggedInUser.initials = initial;
                  loggedInUser.designation = designation;
                  loggedInUser.department = dept;
                  loggedInUser.isHod = checkbox.isChecked;
                  debugPrint('Teacher page: $loggedInUser', wrapWidth: 1024);
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
