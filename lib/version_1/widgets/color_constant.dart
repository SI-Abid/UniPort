import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color cyanA400 = fromHex('#00e5db');

  static Color tealA700 = fromHex('#05b0a8');

  static Color gray600 = fromHex('#7a7a7a');

  static Color gray800 = fromHex('#464646');

  static Color whiteA7003d = fromHex('#3dffffff');

  static Color black9003f = fromHex('#3f000000');

  static Color teal6007a = fromHex('#7a188f79');

  static Color gray100 = fromHex('#f5f5f5');

  static Color teal60051 = fromHex('#51188f79');

  static Color teal600 = fromHex('#188f79');

  static Color cyan50001 = fromHex('#09d1d5');

  static Color black900 = fromHex('#000000');

  static Color teal700 = fromHex('#00726d');

  static Color blueGray900Dd = fromHex('#dd2e2e2e');

  static Color cyan50002 = fromHex('#06c9ca');

  static Color whiteA700 = fromHex('#ffffff');

  static Color cyan700 = fromHex('#01a7a0');

  static Color cyan500 = fromHex('#0cc5c3');

  static Color whiteA700B7 = fromHex('#b7ffffff');

  static Color deepOrangeA40014 = fromHex('#14ff4c00');

  static Color deepPurpleA70014 = fromHex('#144500ff');

  static Color blueGray1003d = fromHex('#3dd9d9d9');

  static Color gray50001 = fromHex('#a5a5a5');

  static Color teal60014 = fromHex('#14178f78');

  static Color gray500 = fromHex('#a3a3a3');

  static Color bluegray400 = fromHex('#888888');

  static Color whiteA70089 = fromHex('#89ffffff');

  static Color greenA40014 = fromHex('#1404ff4a');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
