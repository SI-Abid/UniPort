import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void unavailableFeatureToast() => Fluttertoast.showToast(
      msg: 'Feature not available yet',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.yellow.shade500,
      textColor: Colors.black,
      fontSize: 16.0,
    );
