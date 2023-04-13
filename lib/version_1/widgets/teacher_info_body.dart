import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/models/user.dart';

import '../providers/providers.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class TeacherInfoBody extends ConsumerStatefulWidget {
  const TeacherInfoBody({super.key});

  @override
  ConsumerState<TeacherInfoBody> createState() => _TeacherInfoBodyState();
}

class _TeacherInfoBodyState extends ConsumerState<TeacherInfoBody> {
  final tIdController = TextEditingController();

  final intialController = TextEditingController();

  final deptController = TextEditingController();

  final designationController = TextEditingController();

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
              _getDesignationSelector(context),
              const SizedBox(height: 5),
              // Should be Department
              _getDepartmentSelector(context),
              const SizedBox(height: 5),
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
                  ref.read(userProvider.notifier).setAcademicInfo(UserModel(
                        teacherId: tIdController.text.trim(),
                        initials: intialController.text.trim().toUpperCase(),
                        department: deptController.text.trim(),
                        designation: designationController.text.trim(),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _getDesignationSelector(BuildContext context) {
    final List<String> designationList = [
      'Assistant Professor',
      'Associate Professor',
      'Lecturer',
      'Professor',
    ];
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 65,
      child: DropdownButtonFormField(
        validator: designationValidator,
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
          hintText: 'Designation',
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
        items: designationList
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (value) => setState(() {
          designationController.text = value.toString();
        }),
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
        onChanged: (value) => setState(() {
          deptController.text = value.toString();
        }),
      ),
    );
  }
}
