import 'package:flutter/material.dart';

var lightThemeData = ThemeData(
  backgroundColor: Colors.white, // bg color
  primaryColor: Colors.black, // text and icons
  cardColor: Colors.grey[400], // container
  primaryColorLight: Colors.white, // some containers
  primaryColorDark: Colors.white, // text and icons inside of containers
);

var darkThemeData = ThemeData(
  backgroundColor: Colors.black87,
  primaryColor: Colors.white,
  cardColor: Colors.white,
  primaryColorDark: Colors.black,
  primaryColorLight: Colors.grey[800],
);
