import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/auth_controller.dart';

class GoogleLoginButton extends ConsumerStatefulWidget {
  const GoogleLoginButton({super.key});

  @override
  ConsumerState<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends ConsumerState<GoogleLoginButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(5),
          backgroundColor: MaterialStateProperty.all<Color>(
            Colors.white,
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () => ref.read(authControllerProvider).signInWithGoogle(context),
        child: SvgPicture.asset(
          alignment: Alignment.bottomCenter,
          'assets/images/logo_google_icon.svg',
          height: 35,
        ),
      ),
    );
  }
}
