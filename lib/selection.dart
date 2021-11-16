import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/widgets/objects/majorobject.dart';
import 'package:timely/widgets/text.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'animations/floatinganimation.dart';
import 'calendar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Selection extends StatefulWidget {
  const Selection({Key? key}) : super(key: key);

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection>
    with SingleTickerProviderStateMixin {
  List<Major> listToSearch = [];
  List<String> listOfMajors = [];
  String selectedMajor = "";
  Color? myButtonColor = Colors.transparent;
  late List selectedList;
  late AnimationController controller;
  late Animation<Offset> offset;

  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    offset = Tween<Offset>(
            begin: const Offset(0.0, 30.0), end: const Offset(0.0, 0.0))
        .animate(controller);

    gettingMajor();
  }

  saveMajor(String majorId, String majorLbl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_major_key', majorId + "//" + majorLbl);
  }

  gettingMajor() async {
    await getMajors().then((value) {
      for (var item in value) {
        listToSearch.add(item);
        listOfMajors.add(item.label);
      }
    });
    setState(() {});
  }

  Future<List<Major>> getMajors() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // ignore: prefer_typing_uninitialized_variables
    var jsonData;
    List<Major> majors = [];
    // ignore: await_only_futures
    jsonData = await prefs.getString('major_key');

    if (jsonData.toString() == "null") {
      var data = await http.get(Uri.parse(
          'https://issatso-majors-schedule.herokuapp.com/api/v1/majors/'));
      jsonData = json.decode(data.body);
      List myMajors = jsonData;

      for (int i = 0; i < myMajors.length; i++) {
        Major major =
            Major(majorId: myMajors[i]["majorId"], label: myMajors[i]["label"]);
        majors.add(major);
      }
      final String encodedData = Major.encode(majors);
      await prefs.setString('major_key', encodedData);
    } else {
      // ignore: await_only_futures
      jsonData = await prefs.getString('major_key');
      majors = Major.decode(jsonData);
    }
    return majors;
  }

  String getMajorId(majorLbl) {
    String majorId = "";
    for (int i = 0; i < listToSearch.length; i++) {
      if (listToSearch[i].label == majorLbl) {
        majorId = listToSearch[i].majorId;
      }
    }
    return majorId;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: Theme.of(context).backgroundColor,
          child: Stack(
            children: [
              Positioned(
                  bottom: 10.0,
                  left: MediaQuery.of(context).size.width * 0.01,
                  child: const Opacity(
                      opacity: 0.7,
                      child: AnimatedImage(
                        img: 'lib/animations/bg.png',
                        size: 5.0,
                      ))),
              Container(
                width: size.width,
                height: size.height,
                padding: EdgeInsets.only(top: size.height * 0.09),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.06,
                      ),
                      Text(
                        "PICK YOUR MAJOR",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Comforta',
                          fontWeight: FontWeight.bold,
                          fontSize: 45.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      listOfMajors.isEmpty
                          ? CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            )
                          : SizedBox(
                              width: size.width * 0.70,
                              child: CustomSearchableDropDown(
                                padding: const EdgeInsets.all(5.0),
                                backgroundColor: const Color(0x19101010),
                                dropdownBackgroundColor: Colors.white,
                                primaryColor: Colors.black,
                                items: listOfMajors,
                                dropDownMenuItems: listOfMajors,
                                label: 'Select a major',
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down_circle_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                                dropdownLabelStyle: const TextStyle(
                                  fontFamily: 'Comforta',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                                labelStyle: TextStyle(
                                  fontFamily: 'Comforta',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedMajor = value;
                                    });
                                    controller.forward();
                                  } else {
                                    selectedMajor = "";
                                  }
                                },
                              ),
                            ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      SlideTransition(
                        position: offset,
                        child: SizedBox(
                          width: size.width * 0.65,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                myweight: FontWeight.bold,
                                mytext: "Subgroup",
                                textSize: 18.0,
                                mycolor: Theme.of(context).primaryColor,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyText(
                                    myweight: FontWeight.bold,
                                    mytext: "01",
                                    textSize: 18.0,
                                    mycolor: Theme.of(context).primaryColor,
                                  ),
                                  Switch(
                                    value: isSwitched,
                                    onChanged: (value) async {
                                      setState(() {
                                        isSwitched = value;
                                      });
                                    },
                                    inactiveTrackColor: Colors.grey,
                                    activeTrackColor: Colors.grey[350],
                                    activeColor: Colors.white,
                                  ),
                                  MyText(
                                    myweight: FontWeight.bold,
                                    mytext: "02",
                                    textSize: 18.0,
                                    mycolor: Theme.of(context).primaryColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      SlideTransition(
                        position: offset,
                        child: SizedBox(
                          width: size.width * 0.65,
                          // ignore: deprecated_member_use
                          child: FlatButton(
                            onPressed: () {
                              setState(() {
                                // ignore: unnecessary_null_comparison
                                if (selectedMajor != null) {
                                  saveMajor(
                                      getMajorId(selectedMajor), selectedMajor);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Calendar(
                                            majorId: getMajorId(selectedMajor),
                                            majorLbl: selectedMajor,
                                            grp: isSwitched,
                                          )));
                                }
                              });
                            },
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      mycolor:
                                          Theme.of(context).primaryColorDark,
                                      mytext: "I MADE MY CHOICE ",
                                      myweight: FontWeight.normal,
                                      textSize: 15.0,
                                    ),
                                    Icon(
                                      Icons.done,
                                      color: Theme.of(context).primaryColorDark,
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
