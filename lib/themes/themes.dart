import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

class AppThemes {
  // ignore: constant_identifier_names
  static const int Light = 0;
  // ignore: constant_identifier_names
  static const int Dark = 1;
}

final themeCollection = ThemeCollection(
  themes: {
    AppThemes.Light: ThemeData(
      secondaryHeaderColor: const Color(0xffc7dcf0),
      backgroundColor: const Color(0xffccdef0), // bg color
      primaryColor: Colors.black, // text and icons
      cardColor: const Color(0xff556170), // container
      primaryColorLight: Colors.white, // some containers
      primaryColorDark: Colors.white, // text and icons inside of containers
    ),
    AppThemes.Dark: ThemeData(
      secondaryHeaderColor: const Color(0xff0c0e12),
      backgroundColor: const Color(0xff12151a),
      primaryColor: Colors.white,
      cardColor: Colors.white,
      primaryColorDark: Colors.black,
      primaryColorLight: Colors.grey[800],
    ),
  },
);
