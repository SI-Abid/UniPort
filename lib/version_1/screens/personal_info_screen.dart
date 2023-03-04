import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/helper.dart';
import '../services/providers.dart';
import '../widgets/widgets.dart';
import '../screens/screens.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

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
              //mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                PersonalInfoHeaderText(),
                SizedBox(height: 40),
                PersonalInfoBody()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PersonalInfoHeaderText extends StatelessWidget {
  const PersonalInfoHeaderText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Personal Information",
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

class PersonalInfoBody extends StatefulWidget {
  const PersonalInfoBody({Key? key}) : super(key: key);

  @override
  State<PersonalInfoBody> createState() => _PersonalInfoBodyState();
}

class _PersonalInfoBodyState extends State<PersonalInfoBody> {
  final emailController = TextEditingController();

  final fNameController = TextEditingController();

  final lNameController = TextEditingController();

  final stdController = TextEditingController();

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
              // Should be First Name
              CustomTextField(
                controller: fNameController,
                hintText: 'First Name',
                formValidator: nameValidator,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 8),

              // Should be Last Name
              CustomTextField(
                controller: lNameController,
                hintText: 'Last Name',
                formValidator: nameValidator,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 8),

              // Should be Contact
              CustomTextField(
                controller: stdController,
                hintText: 'Contact',
                formValidator: phoneValidator,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 10),

              // Next Button
              ActionButton(
                text: 'NEXT',
                onPressed: () {
                  if (formKey.currentState!.validate() == false) {
                    return;
                  }
                  formKey.currentState!.save();
                  String fname = fNameController.text.trim();
                  String lname = lNameController.text.trim();
                  String std = stdController.text.trim();
                  loggedInUser.firstName = fname;
                  loggedInUser.lastName = lname;
                  loggedInUser.contact = std;
                  print('Personal page: $loggedInUser');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcademicInfoRegScreen(),
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
