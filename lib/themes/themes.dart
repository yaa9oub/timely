import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static const int Light = 0;
  static const int Dark = 1;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.Light: ThemeData(
      backgroundColor: const Color(0xffccdef0), // bg color
      primaryColor: Colors.black, // text and icons
      cardColor: const Color(0xff556170), // container
      primaryColorLight: Colors.white, // some containers
      primaryColorDark: Colors.white, // text and icons inside of containers
    ),
    AppThemes.Dark: ThemeData(
      backgroundColor: const Color(0xff1a1e24),
      primaryColor: Colors.white,
      cardColor: Colors.white,
      primaryColorDark: Colors.black,
      primaryColorLight: Colors.grey[800],
    ),
  },
);
