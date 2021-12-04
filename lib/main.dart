import 'dart:async';

import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/animations/floatinganimation.dart';
import 'package:timely/calendar.dart';
import 'package:timely/selection.dart';
import 'package:timely/themes/themes.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:timely/widgets/text.dart';

void main() {
  runApp(const MyApp());
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
    //checkFirstSeen();
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
        lover: false,
        loverMajorId: '',
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

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      getSavedMajor().then((value) => {foo(value)});
    } else {
      await prefs.setBool('seen', true);
      nextWidget = const IntroScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
        themeCollection: themeCollection, // optional, default id is 0
        builder: (context, theme) {
          return MaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: nextWidget,
          );
        });
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Theme.of(context).backgroundColor,
      isTopSafeArea: true,
      pages: getPages(context),
      showNextButton: false,
      done: const MyText(
          mytext: "Done",
          textSize: 18.0,
          myweight: FontWeight.w900,
          mycolor: Colors.black),
      onDone: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const Selection()));
      },
    );
  }

  List<PageViewModel> getPages(context) {
    return [
      PageViewModel(
          image: Image.asset(
            "lib/animations/f.gif",
            scale: 2,
          ),
          title: "Welcome to Timely",
          bodyWidget: SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  " + This application is an alternative to the shitty timetable on the website.",
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + Make sure to follow the rest of the tutorial for a better experience.",
                  style: TextStyle(
                      fontSize: 17.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + Developed by The Wings of Freedom team.",
                  style: TextStyle(
                      fontSize: 16.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
      PageViewModel(
          image: const Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: AnimatedImage(img: "lib/animations/1st.png", size: 8.0),
          ),
          title: "Simple & Customizable",
          bodyWidget: SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  " + You can customize your themes and colors according to your needs.",
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + No internet needed after the first fetch.",
                  style: TextStyle(
                      fontSize: 17.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + Get faster look to your agenda.",
                  style: TextStyle(
                      fontSize: 16.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
      PageViewModel(
          image: const Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: AnimatedImage(img: "lib/animations/2nd.png", size: 7),
          ),
          title: "Track your absence",
          bodyWidget: SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  " + You can track wether you missed a class or not.",
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + After missing a class, a one click is all you need.",
                  style: TextStyle(
                      fontSize: 17.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + One click a day, keeps the elimination away.",
                  style: TextStyle(
                      fontSize: 16.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
      PageViewModel(
          image: const Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: AnimatedImage(img: "lib/animations/3rd.png", size: 7.0),
          ),
          title: "Stalk your lover",
          bodyWidget: SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  " + You can also stalk your lover's movements.",
                  style: TextStyle(
                      fontSize: 18.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + Find your lover easier with Timely.",
                  style: TextStyle(
                      fontSize: 17.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
                Text(
                  " + Don't forget to invite us to the wedding.",
                  style: TextStyle(
                      fontSize: 16.0, color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
    ];
  }
}
