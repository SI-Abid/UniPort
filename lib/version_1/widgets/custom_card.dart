import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final void Function()? action;
  final String actionName;
  final String routeName;
  const CustomCard({
    super.key,
    required this.iconPath,
    required this.routeName,
    required this.title,
    required this.subtitle,
    this.action,
    required this.actionName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (action != null) {
          action!();
        } else {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: SizedBox(
        width: 150,
        height: 200,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.white,
          shadowColor: Colors.blueGrey.shade50,
          elevation: 8.0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  width: 65,
                  height: 65,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.teal.shade100,
                      width: 1,
                    ),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    color: Colors.teal[800],
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  title,
                  style: GoogleFonts.sen(
                    fontSize: 12,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  subtitle,
                  style: GoogleFonts.sen(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  height: 45,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Text(
                    actionName,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: GoogleFonts.sen(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
