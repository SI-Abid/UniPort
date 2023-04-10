import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uniport/version_1/models/batch_model.dart';
import 'package:uniport/version_1/providers/auth_controller.dart';
import 'package:uniport/version_1/providers/chat_controller.dart';

import '../services/helper.dart';
import '../widgets/widgets.dart';

class StudentInfoBody extends ConsumerStatefulWidget {
  const StudentInfoBody({super.key});

  @override
  ConsumerState<StudentInfoBody> createState() => _StudentInfoBodyState();
}

class _StudentInfoBodyState extends ConsumerState<StudentInfoBody> {
  final sIdController = TextEditingController();

  final sectionController = TextEditingController();

  final batchController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  List<String> sectionItems = [];

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
              _sectionSelector(
                context,
                sectionController,
              ),
              const SizedBox(height: 5),
              // Should be Batch
              _batchSelector(
                context,
                batchController,
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
                  final data = {
                    'usertype': 'student',
                    'studentId': sIdController.text.trim(),
                    'section': sectionController.text.trim(),
                    'batch': batchController.text.trim(),
                  };
                  formKey.currentState!.save();
                  ref
                      .read(authControllerProvider)
                      .createUser(context, data: data);
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
        decoration: _getDecoration(),
        items: departmentList
            .map((e) => DropdownMenuItem(
                  alignment: Alignment.centerLeft,
                  value: e,
                  child: Text(e),
                ))
            .toList(),
        onChanged: (value) =>
            ref.read(authControllerProvider).createUser(context, data: {
          'department': value,
        }),
      ),
    );
  }

  InputDecoration _getDecoration() {
    return InputDecoration(
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
    );
  }

  // DONE: dynamic batch selector
  _batchSelector(BuildContext context, TextEditingController controller) {
    return DropdownButtonFormField(
      items: ref.watch(batchProvider).when(data: (data) {
        return data.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(e.batch),
          );
        }).toList();
      }, loading: () {
        return const [];
      }, error: (e, s) {
        return const [];
      }),
      validator: (value) => batchValidator((value as BatchModel).batch),
      onChanged: (value) {
        setState(() {
          sectionItems = (value as BatchModel).sections;
        });
        controller.text = (value as BatchModel).batch;
      },
      decoration: _getDecoration(),
    );
  }

  _sectionSelector(BuildContext context, TextEditingController controller) {
    return DropdownButtonFormField(
      items: sectionItems.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(e),
        );
      }).toList(),
      validator: sectionValidator,
      onChanged: (value) {
        controller.text = value.toString();
      },
      decoration: _getDecoration(),
    );
  }
}
