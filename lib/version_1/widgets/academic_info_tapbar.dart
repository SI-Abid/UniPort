import 'package:flutter/material.dart';

import 'color_constant.dart';

class AcademicInfoTapbar extends StatelessWidget {
  final Function(String) onTabChanged;
  const AcademicInfoTapbar({super.key, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: TabBar(
            indicator: BoxDecoration(
              color: ColorConstant.teal700,
              borderRadius: BorderRadius.circular(5),
            ),
            tabs: const [
              Tab(text: 'Student'),
              Tab(text: 'Teacher'),
            ],
            onTap: (index) {
              if (index == 0) {
                onTabChanged("student");
              } else {
                onTabChanged("teacher");
              }
            },
          ),
        ),
      ),
    );
  }
}
