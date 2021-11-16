import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/calendar.dart';
import 'package:timely/selection.dart';
import 'package:timely/themes/themes.dart';
import 'package:dynamic_themes/dynamic_themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? nextWidget;

  @override
  void initState() {
    super.initState();
    getSavedMajor().then((value) => {foo(value)});
  }

  foo(value) {
    if (value != "") {
      String _majorId;
      String _majorLbl;
      _majorId = value.substring(0, value.indexOf("//"));
      _majorLbl = value.substring(value.indexOf("//") + 2, value.length);
      nextWidget = Calendar(
        majorId: _majorId,
        majorLbl: _majorLbl,
        grp: false,
      );
      setState(() {});
    } else {
      nextWidget = Selection();
      setState(() {});
    }
  }

  Future<String> getSavedMajor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String _savedMajor = "";
    if (prefs.getString('selected_major_key') != null) {
      _savedMajor = prefs.getString('selected_major_key')!;
    } else {
      _savedMajor = "";
    }
    return _savedMajor;
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        themeCollection: themeCollection, // optional, default id is 0
        builder: (context, theme) {
          return MaterialApp(
            title: 'dynamic_themes example',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: nextWidget,
          );
        });
  }
}
