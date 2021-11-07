import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/animations/animation.dart';
import 'package:timely/coloreditor.dart';
import 'package:timely/selection.dart';
import 'package:timely/widgets/description.dart';
import 'package:timely/widgets/objects/dayobject.dart';
import 'package:timely/widgets/objects/sessionobject.dart';
import 'package:timely/widgets/session.dart';
import 'package:timely/widgets/text.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'animations/floatinganimation.dart';

class Calendar extends StatefulWidget {
  final String majorId, majorLbl;
  final bool grp;
  const Calendar(
      {Key? key,
      required this.majorId,
      required this.majorLbl,
      required this.grp})
      : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  List<TheDay> myDays = [];
  IconData darkModeIcon = Icons.dark_mode;
  late AnimationController _animationController;
  String currentDay = "";
  var selectedDay = -1;
  late AutoScrollController controller;
  late bool isSwitched;

  @override
  void initState() {
    super.initState();
    setState(() {});
    isSwitched = widget.grp;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    DateTime date = DateTime.now();
    if (DateFormat('EEEE').format(date) == "Sunday") {
      currentDay = "Monday";
    } else {
      currentDay = DateFormat('EEEE').format(date);
    }
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.horizontal);
    gettingDays(isSwitched);
  }

  Future<List<TheDay>> getDays(bool groupe) async {
    String x;
    if (groupe) {
      x = '2';
    } else {
      x = '1';
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<TheDay> days = [];
    var jsonData;
    jsonData = await prefs.getString(widget.majorId);

    if (jsonData.toString() == "null") {
      print("schedule not saved");
      var data = await http.get(Uri.parse(
          'https://issatso-majors-schedule.herokuapp.com/api/v1/majors/' +
              widget.majorId));
      jsonData = json.decode(data.body);
      days = getDataFromApi(jsonData, x);
      await prefs.setString(widget.majorId, data.body);
      //await prefs.setString('selected_major_key', data.body);
    } else {
      print("schedule saved");
      String? dataBody = await prefs.getString(widget.majorId);
      if (dataBody != null) {
        jsonData = json.decode(dataBody);
        days = getDataFromApi(jsonData, x);
      }
    }

    return days;
  }

  gettingDays(bool g) async {
    await getDays(g).then((value) {
      for (var element in value) {
        myDays.add(element);
      }
    });
    setState(() {});
  }

  int getSelectedDay() {
    int daySelected = 0;

    if (selectedDay == -1) {
      switch (currentDay) {
        case 'Monday':
          daySelected = 0;
          break;
        case 'Tuesday':
          daySelected = 1;
          break;
        case 'Wednesday':
          daySelected = 2;
          break;
        case 'Thursday':
          daySelected = 3;
          break;
        case 'Friday':
          daySelected = 4;
          break;
        case 'Saturday':
          daySelected = 5;
          break;
        default:
      }
    } else {
      daySelected = selectedDay;
    }
    return daySelected;
  }

  String getRegime() {
    String regime = '';
    var now = DateTime.now();
    var monthFormatter = DateFormat('MM');
    String month = monthFormatter.format(now);
    var dayFormatter = DateFormat('MM');
    String day = dayFormatter.format(now);

    //1
    if ((int.parse(day) >= 6 || int.parse(day) <= 11) &&
        int.parse(month) == 9) {
      regime = "QA";
    }
    //2
    if ((int.parse(day) >= 13 || int.parse(day) <= 18) &&
        int.parse(month) == 9) {
      regime = "QB";
    }
    //3
    if ((int.parse(day) >= 20 || int.parse(day) <= 25) &&
        int.parse(month) == 9) {
      regime = "QA";
    }
    //4
    if ((int.parse(day) >= 27 || int.parse(day) <= 09) &&
        int.parse(month) == 10) {
      regime = "QB";
    }
    //5
    if ((int.parse(day) >= 04 || int.parse(day) <= 09) &&
        int.parse(month) == 10) {
      regime = "QA";
    }
    //6
    if ((int.parse(day) >= 11 || int.parse(day) <= 16) &&
        int.parse(month) == 10) {
      regime = "QB";
    }
    //7
    if ((int.parse(day) >= 18 || int.parse(day) <= 23) &&
        int.parse(month) == 10) {
      regime = "QA/Z3/M1";
    }
    //8
    if ((int.parse(day) >= 25 || int.parse(day) <= 30) &&
        int.parse(month) == 10) {
      regime = "QB/Z4/M1";
    }
    //9
    if ((int.parse(day) >= 1 || int.parse(day) <= 6) &&
        int.parse(month) == 11) {
      regime = "QA/Z3/M2";
    }
    //10
    if ((int.parse(day) >= 8 || int.parse(day) <= 13) &&
        int.parse(month) == 11) {
      regime = "QB/Z4/M2";
    }
    //11
    if ((int.parse(day) >= 15 || int.parse(day) <= 20) &&
        int.parse(month) == 11) {
      regime = "QA/Z3/M2";
    }
    //12
    if ((int.parse(day) >= 22 || int.parse(day) <= 27) &&
        int.parse(month) == 11) {
      regime = "QB/Z4/M2";
    }
    //13
    if (((int.parse(day) >= 29 || int.parse(day) <= 30) &&
            int.parse(month) == 11) ||
        (int.parse(day) >= 1 || int.parse(day) <= 4) &&
            int.parse(month) == 12) {
      regime = "QA/Z3/M2";
    }
    //14
    if ((int.parse(day) >= 6 || int.parse(day) <= 11) &&
        int.parse(month) == 12) {
      regime = "QB/Z4/M2";
    }
    //15
    if ((int.parse(day) >= 13 || int.parse(day) <= 18) &&
        int.parse(month) == 12) {
      regime = "QA/M2";
    }

    return regime;
  }

  List<Widget> getDaysWidget() {
    List<Widget> myDaysListWidget = [];
    for (var i = 0; i < days.length; i++) {
      myDaysListWidget.add(
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: MyText(
            mytext: days[i].substring(0, 1),
            textSize: 16.0,
            myweight: FontWeight.bold,
            mycolor: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return myDaysListWidget;
  }

  List<Widget> getScheduleWidget() {
    List<Widget> schedule = [];
    for (var i = 0; i < days.length; i++) {
      schedule.add(myDays.isEmpty
          ? const Center(child: AnimatedImage())
          : ListView.builder(
              itemCount: myDays[i].sessions.length,
              itemBuilder: (BuildContext context, int index) {
                return SlideAnimation(
                  slideDirection: SlideDirection.fromBottom,
                  animationController: _animationController,
                  itemCount: myDays[i].sessions.length,
                  position: index,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        SessionWidget(
                          borderColor: Theme.of(context).primaryColor,
                          session: myDays[i].sessions[index].sessionNumber,
                          time: myDays[i].sessions[index].time,
                        ),
                        DescriptionWidget(
                          desc: myDays[i].sessions[index].label,
                          type: myDays[i].sessions[index].type,
                          classroom: myDays[i].sessions[index].classroom,
                          regime: myDays[i].sessions[index].regime,
                          borderColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              }));
    }
    return schedule;
  }

  List<TheDay> getDataFromApi(jsonData, String x) {
    List<TheDay> days = [];
    jsonData['schedule'][x].keys;
    //To run through all days
    for (var currentDay in jsonData['schedule'][x].keys) {
      List<Session> mySessions = [];
      //To run through all the sessions
      for (var currentSession in jsonData['schedule'][x][currentDay].keys) {
        List s = jsonData['schedule'][x][currentDay][currentSession];
        String lbl = '', classRoom = '', type = '', regime = '';
        //To run through eah session

        for (int i = 0; i < s.length; i++) {
          type = jsonData['schedule'][x][currentDay][currentSession][i]['type'];
          lbl = jsonData['schedule'][x][currentDay][currentSession][i]['desc'];
          classRoom = jsonData['schedule'][x][currentDay][currentSession][i]
              ['classroom'];

          if (jsonData['schedule'][x][currentDay][currentSession][i]
                  ['regime'] ==
              null) {
            regime = '';
            classRoom = '';
          } else {
            regime = jsonData['schedule'][x][currentDay][currentSession][i]
                ['regime'];
          }

          String time = "";

          switch (currentSession) {
            case "S1":
              time = '8.30-10';
              break;
            case "S2":
              time = '10.10-11.40';
              break;
            case "S3":
              time = '11.50-13.20';
              break;
            case "S4":
              time = '13.50-15.20';
              break;
            case "S5":
              time = '15.30-17.00';
              break;
            case "S6":
              time = '17.10-18.40';
              break;
            case "S4'":
              time = '13.30-15.00';
              break;
            default:
          }

          Session session = Session(
              sessionNumber: currentSession,
              time: time,
              label: lbl,
              type: type,
              classroom: classRoom,
              regime: regime);
          mySessions.add(session);
        }
      }

      switch (currentDay) {
        case "1-Lundi":
          currentDay = "Monday";
          break;
        case "2-Mardi":
          currentDay = "Tuesday";
          break;
        case "3-Mercredi":
          currentDay = "Wednesday";
          break;
        case "4-Jeudi":
          currentDay = "Thursday";
          break;
        case "5-Vendredi":
          currentDay = "Friday";
          break;
        case "6-Samedi":
          currentDay = "Saturday";
          break;
        default:
      }

      TheDay myDay = TheDay(day: currentDay, sessions: mySessions);
      days.add(myDay);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        initialIndex: getSelectedDay(),
        length: days.length,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  selectedDay = index;
                });
              },
              tabs: getDaysWidget(),
              indicatorColor:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
            ),
            leading: Container(),
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0.5,
            toolbarHeight: size.height * 0.16,
            flexibleSpace: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              child: SizedBox(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            MyText(
                              myweight: FontWeight.w800,
                              mytext: widget.majorLbl,
                              textSize: 20.0,
                              mycolor: Theme.of(context).primaryColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Selection()));
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MyText(
                              myweight: FontWeight.w800,
                              mytext: "01",
                              textSize: 18.0,
                              mycolor: Theme.of(context).primaryColor,
                            ),
                            Switch(
                              value: isSwitched,
                              onChanged: (value) async {
                                setState(() {
                                  isSwitched = value;
                                  myDays = [];
                                });
                                await gettingDays(value);
                              },
                              inactiveTrackColor: Colors.grey,
                              activeTrackColor: Colors.grey[350],
                              activeColor: Colors.white,
                            ),
                            MyText(
                              myweight: FontWeight.w800,
                              mytext: "02",
                              textSize: 18.0,
                              mycolor: Theme.of(context).primaryColor,
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          myweight: FontWeight.w800,
                          mytext: "Week " + getRegime(),
                          textSize: 19.0,
                          mycolor: Theme.of(context).primaryColor,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(darkModeIcon),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                setState(() {
                                  if (darkModeIcon == Icons.dark_mode) {
                                    darkModeIcon = Icons.light_mode;
                                  } else {
                                    darkModeIcon = Icons.dark_mode;
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ColorEditor(
                                          grp: true,
                                          majorId: widget.majorId,
                                          majorLbl: widget.majorLbl,
                                        )));
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            color: Theme.of(context).backgroundColor,
            child: TabBarView(
              children: getScheduleWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
