import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uniport/version_1/providers/user_provider.dart';

// ignore: must_be_immutable
class CustomCheckBox extends ConsumerStatefulWidget {
  CustomCheckBox({super.key, required this.text});

  final String text;
  bool _isChecked = false;
  bool get isChecked => _isChecked;

  @override
  ConsumerState<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends ConsumerState<CustomCheckBox> {
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
              ref.read(userProvider.notifier).setIsHod(value);
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
