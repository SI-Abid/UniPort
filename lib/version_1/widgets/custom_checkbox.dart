import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCheckBox extends StatefulWidget {
  CustomCheckBox({super.key, required this.text});

  final String text;
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Checkbox(
          checkColor: Colors.white,
          activeColor: const Color.fromARGB(255, 56, 197, 150),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          value: widget.isChecked,
          onChanged: (value) {
            setState(() {
              widget._isChecked = value!;
            });
          },
        ),
        Text(
          widget.text,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 80, 67),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
