import 'package:flutter/material.dart';

class AppFonts {

  static TextTheme appTextTheme(TextTheme base) {
    return base.apply(
      fontFamily: 'OSD Mono',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
  }

  static TextStyle title({
    double size = 22,
    Color color = Colors.white,
    FontWeight weight = FontWeight.bold,
  }) {
    return TextStyle(
      fontFamily: 'Pixeled',

      package: null,

      fontSize: size,
      color: color,
      fontWeight: weight,

      height: 1.2,

      textBaseline: TextBaseline.alphabetic,
    );
  }

  static TextStyle body({
    double size = 22,
    Color color = Colors.white,
    FontWeight weight = FontWeight.normal,
  }) {
    return TextStyle(
      fontFamily: 'OSD Mono',

      package: null,

      fontSize: size,
      color: color,
      fontWeight: weight,

      height: 1.2,

      textBaseline: TextBaseline.alphabetic,
    );
  }
}