import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/widgets.dart';

class WelcomePageScreen extends StatefulWidget {
  const WelcomePageScreen({super.key});

  @override
  State<WelcomePageScreen> createState() => _WelcomePageScreenState();
}

class _WelcomePageScreenState extends State<WelcomePageScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  void navigateToNextScreen() {
    Future.delayed(
      const Duration(
        seconds: 6,
      ),
      () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray100,
        body: Container(
          padding: const EdgeInsets.only(top: 48, bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/images/img_152keylinesquare.png'),
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: AppTitle(),
              ),
              const Spacer(),
              SizedBox(
                height: 38,
                width: 105,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/images/img_group114.svg'),
                            Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 8),
                              child: Text(
                                "tripleS",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.sen(
                                  letterSpacing: 2,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          "from",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.sen(
                            letterSpacing: 2,
                            height: 1,
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
