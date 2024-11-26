import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../services/helper.dart';
import '../widgets/widgets.dart';

class PersonalInfoScreen extends ConsumerWidget {
  static const String routeName = '/personal-info';
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  final fNameController = TextEditingController();

  final lNameController = TextEditingController();

  final phoneController = TextEditingController();

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
                controller: phoneController,
                hintText: 'Contact',
                formValidator: phoneValidator,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 10),

              // Next Button
              Consumer(builder: (context, ref, child) {
                return ActionButton(
                  text: 'NEXT',
                  onPressed: () {
                    if (formKey.currentState!.validate() == false) {
                      return;
                    }
                    formKey.currentState!.save();
                    // DONE: add navigation to the next screen
                    ref.read(userProvider.notifier).setPersonalInfo(UserModel(
                          firstName: fNameController.text.trim(),
                          lastName: lNameController.text.trim(),
                          contact: phoneController.text.trim(),
                        ));
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
