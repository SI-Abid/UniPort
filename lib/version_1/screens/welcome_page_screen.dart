import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    // navigateToNextScreen();
  }

  void navigateToNextScreen() {
    Future.delayed(
      const Duration(
        seconds: 3,
      ),
      () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f5),
        body: Center(
          child: Container(
            // color: Colors.amber,
            padding: const EdgeInsets.only(bottom: 48, top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.275)
                          .copyWith(bottom: 0),
                  child: Image.asset('assets/images/img_152keylinesquare.png'),
                ),
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: AppTitle(),
                ),
                const Spacer(),
                SizedBox(
                  height: 55,
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
                              SvgPicture.asset(
                                'assets/images/img_group114.svg',
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 8),
                                child: Text(
                                  "from \n tripleS",
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
                      // Align(
                      //   alignment: Alignment.topRight,
                      //   child: Padding(
                      //     padding: const EdgeInsets.only(right: 30),
                      //     child: Text("from",
                      //         overflow: TextOverflow.ellipsis,
                      //         textAlign: TextAlign.left,
                      //         style: GoogleFonts.sen(
                      //           letterSpacing: 2,
                      //           height: 1,
                      //         )),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
