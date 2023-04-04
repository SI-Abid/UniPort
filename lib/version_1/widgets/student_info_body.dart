import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../services/helper.dart';
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
              _getDepartmentSelector(context),
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
                  formKey.currentState!.save();
                  context.read<AuthProvider>().setData(
                        studentId: sid,
                        section: section,
                        batch: batch,
                      );
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

  SizedBox _getDepartmentSelector(BuildContext context) {
    final List<String> departmentList = [
      'BuA',
      'CSE',
      'ENG',
      'ARC',
      'LAW',
      'CE',
      'EEE',
      'IST',
      'PH',
      'THM',
      'BANG',
    ];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 65,
      child: DropdownButtonFormField(
        menuMaxHeight: 300,
        validator: departmentValidator,
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
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
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
          hintText: 'Department',
          hintStyle: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xffababab),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 24, 143, 121),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 24, 143, 121),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 24, 143, 121),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        items: departmentList
            .map((e) => DropdownMenuItem(
                  alignment: Alignment.centerLeft,
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (value) {
          context.read<AuthProvider>().setData(department: value.toString());
        },
      ),
    );
  }
}
