import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'eye_icon.dart';

class PasswordField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? formValidator;
  const PasswordField(
      {super.key,
      this.hintText = 'Enter your password',
      required this.controller,
      this.formValidator});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isObscure = true;
  void toggleObscure() => setState(() => isObscure = !isObscure);
  Widget get suffixIcon => isObscure ? const ClosedEye() : const OpenedEye();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 70,
      child: TextFormField(
          obscureText: isObscure,
          obscuringCharacter: '●',
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          keyboardAppearance: Brightness.light,
          style: GoogleFonts.sen(
            letterSpacing: 0.5,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 24, 143, 121),
          ),
          decoration: InputDecoration(
            constraints: const BoxConstraints(minHeight: 65),
            suffixIcon: IconButton(
              icon: suffixIcon,
              onPressed: toggleObscure,
            ),
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
            hintText: widget.hintText,
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
          ),
          onChanged: (value) => widget.controller.text = value,
          validator: widget.formValidator),
    );
  }
}
