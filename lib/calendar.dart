import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/animations/animation.dart';
import 'package:timely/coloreditor.dart';
import 'package:timely/selection.dart';
import 'package:timely/themes/themes.dart';
import 'package:timely/widgets/objects/abscence.dart';
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
  List<Abscence> abscences = [];
  IconData darkModeIcon = Icons.dark_mode;
  late AnimationController _animationController;
  String currentDay = "";
  var selectedDay = -1;
  late bool isSwitched;
  Color tpcolor = Colors.red, tdcolor = Colors.blue, ccolor = Colors.green;
  List<String> mysessions = ["S1", "S2", "S3", "S4", "S5", "S6"];

  @override
  void initState() {
    super.initState();
    //setState(() {});
    getColors("tp").then((value) {
      setState(() {
        tpcolor = Color(value);
      });
    });
    getColors("td").then((value) {
      setState(() {
        tdcolor = Color(value);
      });
    });
    getColors("c").then((value) {
      setState(() {
        ccolor = Color(value);
      });
    });
    isSwitched = widget.grp;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    DateTime date = DateTime.now();
    if (DateFormat('EEEE').format(date) == "Sunday") {
      currentDay = "Monday";
    } else {
      currentDay = DateFormat('EEEE').format(date);
    }
    gettingDays(isSwitched);
  }

  showAlertDialog(BuildContext context, String lbl, int btn) {
    // set up the buttons
    // ignore: deprecated_member_use
    Widget cancelButton = FlatButton(
      child: const MyText(
          mytext: "NAAH",
          textSize: 14.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // ignore: deprecated_member_use
    Widget continueButton = FlatButton(
      child: const MyText(
          mytext: "HELL YEAH",
          textSize: 14.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      onPressed: () {
        setAbscence(lbl, btn);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).backgroundColor,
      title: const MyText(
          mytext: "Highway To Elimination",
          textSize: 20.0,
          myweight: FontWeight.bold,
          mycolor: Colors.blue),
      content: MyText(
          mytext: btn == 1
              ? "You sure you missed this class?"
              : "You sure you did not miss this class?",
          textSize: 16.0,
          myweight: FontWeight.bold,
          mycolor: Theme.of(context).primaryColor),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget getAbsWidget(int number) {
    return number >= 3
        ? Row(
            children: const [
              Icon(
                Icons.person_off,
                color: Colors.black,
              ),
              Icon(
                Icons.person_off,
                color: Colors.black,
              ),
              Icon(
                Icons.person_off,
                color: Colors.black,
              ),
            ],
          )
        : number == 2
            ? Row(
                children: const [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.person_off,
                    color: Colors.black,
                  ),
                  Icon(
                    Icons.person_off,
                    color: Colors.black,
                  ),
                ],
              )
            : number == 1
                ? Row(
                    children: const [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.person_off,
                        color: Colors.black,
                      ),
                    ],
                  )
                : number == 0
                    ? Row(
                        children: const [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ],
                      )
                    : Container();
  }

  setAbscence(String subject, int btn) async {
    for (var abs in abscences) {
      if (abs.subject == subject) {
        if (btn == 1) {
          if (abs.number < 3) {
            abs.number = abs.number + 1;
          }
        } else {
          if (abs.number > 0) {
            abs.number = abs.number - 1;
          }
        }
        break;
      }
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedData = Abscence.encode(abscences);
    await prefs.setString(widget.majorLbl + 'abscence_key', encodedData);
    setState(() {});
  }

  int getAbscenceNumber(String subject) {
    int number = -1;
    for (var i = 0; i < abscences.length; i++) {
      if (abscences[i].subject == subject) {
        number = abscences[i].number;
        break;
      }
    }
    return number;
  }

  gettingAbscence() async {
    await getAbscence().then((value) {
      for (var item in value) {
        abscences.add(item);
      }
    });
    setState(() {});
  }

  Future<List<Abscence>> getAbscence() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonData;
    List<Abscence> abscences = [];
    if (prefs.containsKey(widget.majorLbl + 'abscence_key')) {
      jsonData = await prefs.getString(widget.majorLbl + 'abscence_key');
      abscences = Abscence.decode(jsonData);
    } else {
      for (var item in myDays) {
        for (var i = 0; i < item.sessions.length; i++) {
          if (item.sessions[i].type != "TP") {
            Abscence abs = Abscence(subject: item.sessions[i].label, number: 0);
            abscences.add(abs);
          }
          Abscence abs = Abscence(subject: item.sessions[i].label, number: 0);
          abscences.add(abs);
        }
      }

      String encodedData = Abscence.encode(abscences);
      await prefs.setString(widget.majorLbl + 'abscence_key', encodedData);
    }
    return abscences;
  }

  Session getSessionDesc(List<Session> session, currentSession) {
    Session s = Session(
        sessionNumber: currentSession,
        time: getSessionTime(currentSession),
        label: "",
        type: "",
        classroom: "",
        regime: "");
    for (var i = 0; i < session.length; i++) {
      if (currentSession == session[i].sessionNumber) {
        s = session[i];
        break;
      }
    }
    return s;
  }

  Widget getAbscenceBloc(bool b, Session session) {
    return b
        ? Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                    color: setSpecificColor(session.type, 15),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getAbsWidget(getAbscenceNumber(session.label)),
                    const SizedBox(
                      width: 10.0,
                    ),
                    //+1
                    InkWell(
                      onTap: () {
                        showAlertDialog(context, session.label, 2);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0.0, 5.0),
                                blurRadius: 10.0,
                                color: Colors.black54,
                              ),
                            ],
                            color: setSpecificColor(session.type, 25),
                            borderRadius: BorderRadius.circular(3)),
                        child: const Icon(
                          Icons.exposure_plus_1,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    //-1
                    InkWell(
                      onTap: () {
                        showAlertDialog(context, session.label, 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0.0, 5.0),
                                blurRadius: 10.0,
                                color: Colors.black54,
                              ),
                            ],
                            color: setSpecificColor(session.type, 25),
                            borderRadius: BorderRadius.circular(3)),
                        child: const Icon(
                          Icons.exposure_minus_1,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  Widget getDescWidget(String day, Session session) {
    return session.label != ""
        ? Column(
            children: [
              //Session
              SessionWidget(
                  session: session.sessionNumber,
                  time: getSessionTime(session.sessionNumber)),
              const SizedBox(
                height: 5.0,
              ),

              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: DynamicTheme.of(context)!.themeId ==
                                  AppThemes.Light.toInt()
                              ? Colors.black26
                              : Colors.black87,
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(4, 4),
                        )
                      ],
                      color: setSpecificColor(session.type, 1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(4.0),
                        topLeft: Radius.circular(4.0),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //type
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: MyText(
                            mytext: session.type,
                            textSize: 15,
                            myweight: FontWeight.normal,
                            mycolor: Colors.white,
                          ),
                        ),
                        //label
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: MyText(
                            mytext: session.label.length > 50
                                ? session.label.substring(5, 30) + ". . ."
                                : session.label
                                    .substring(5, session.label.length),
                            textSize: 22.0,
                            myweight: FontWeight.w600,
                            mycolor: Colors.white,
                          ),
                        ),
                        // regime + class
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                  color: setSpecificColor(session.type, 15),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: 17.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: MyText(
                                        mytext: session.regime,
                                        textSize: 14,
                                        myweight: FontWeight.normal,
                                        mycolor: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(7.0),
                              decoration: BoxDecoration(
                                  color: setSpecificColor(session.type, 15),
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 17.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: MyText(
                                        mytext: session.classroom,
                                        textSize: 14,
                                        myweight: FontWeight.normal,
                                        mycolor: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        // absence
                        getAbscenceBloc(session.type != "TP", session)
                      ],
                    ),
                  ))
            ],
          )
        : day != "Saturday"
            ? Column(
                children: [
                  //Session
                  SessionWidget(
                      session: session.sessionNumber,
                      time: getSessionTime(session.sessionNumber)),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.12,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: const Alignment(-0.9, -0.8),
                          stops: const [0.0, 0.5, 0.5, 1],
                          colors: [
                            Colors.blue[200] as Color,
                            Colors.blue[200] as Color,
                            Theme.of(context).cardColor,
                            Theme.of(context).cardColor,
                          ],
                          tileMode: TileMode.repeated,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: DynamicTheme.of(context)!.themeId ==
                                    AppThemes.Light.toInt()
                                ? Colors.black26
                                : Colors.black87,
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(4, 4),
                          )
                        ],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(4.0),
                          topLeft: Radius.circular(4.0),
                        )),
                    child: null,
                  ),
                ],
              )
            : Container();
  }

  List<Widget> getScheduleWidget() {
    List<Widget> schedule = [];
    for (var i = 0; i < days.length; i++) {
      schedule.add(myDays.isEmpty
          ? const Center(
              child: AnimatedImage(
              img: 'lib/animations/sami.png',
              size: 1.0,
            ))
          : ListView.builder(
              //itemCount: myDays[i].sessions.length,
              itemCount: mysessions.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: isCurrentSession(mysessions[index], myDays[i].day)
                        ? const EdgeInsets.only(
                            left: 35.0, bottom: 8.0, top: 8.0)
                        : const EdgeInsets.only(
                            left: 8.0, bottom: 8.0, top: 8.0),
                    child: getDescWidget(myDays[i].day,
                        getSessionDesc(myDays[i].sessions, mysessions[index])));
              }));
    }
    return schedule;
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
    gettingAbscence();
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
      regime = "QA-Z3-M1";
    }
    //8
    if ((int.parse(day) >= 25 || int.parse(day) <= 30) &&
        int.parse(month) == 10) {
      regime = "QB-Z4-M1";
    }
    //9
    if ((int.parse(day) >= 1 || int.parse(day) <= 6) &&
        int.parse(month) == 11) {
      regime = "QA-Z3-M2";
    }
    //10
    if ((int.parse(day) >= 8 || int.parse(day) <= 13) &&
        int.parse(month) == 11) {
      regime = "QB-Z4-M2";
    }
    //11
    if ((int.parse(day) >= 15 || int.parse(day) <= 20) &&
        int.parse(month) == 11) {
      regime = "QA-Z3-M2";
    }
    //12
    if ((int.parse(day) >= 22 || int.parse(day) <= 27) &&
        int.parse(month) == 11) {
      regime = "QB-Z4-M2";
    }
    //13
    if (((int.parse(day) >= 29 || int.parse(day) <= 30) &&
            int.parse(month) == 11) ||
        (int.parse(day) >= 1 || int.parse(day) <= 4) &&
            int.parse(month) == 12) {
      regime = "QA-Z3-M2";
    }
    //14
    if ((int.parse(day) >= 6 || int.parse(day) <= 11) &&
        int.parse(month) == 12) {
      regime = "QB-Z4-M2";
    }
    //15
    if ((int.parse(day) >= 13 || int.parse(day) <= 18) &&
        int.parse(month) == 12) {
      regime = "QA-M2";
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

  bool isCurrentSession(String session, String day) {
    var now = DateTime.now();
    var formatter = DateFormat.Hm();
    String formattedDate = formatter.format(now);
    int hours = int.parse(formattedDate.substring(0, 2));
    int mins = int.parse(formattedDate.substring(3, 5));
    bool x = false;
    DateTime dateToday = DateTime(DateTime.now().day);

    if (day == DateFormat('EEEE').format(now)) {
      if (session == "S1" && (hours <= 10)) {
        x = true;
      }
      if (session == "S2" &&
          ((hours == 10 && mins >= 5) || (hours == 11 && mins <= 40))) {
        x = true;
      }
      if (session == "S3" &&
          ((hours == 11 && mins >= 50) ||
              (hours == 12) ||
              (hours == 13 && mins <= 20))) {
        x = true;
      }
      if (session == "S4" &&
          ((hours == 13 && mins >= 20) ||
              (hours == 14) ||
              (hours == 15 && mins <= 20))) {
        x = true;
      }
      if (session == "S5" &&
          ((hours == 15 && mins >= 30) ||
              (hours == 16) ||
              (hours == 17 && (mins == 00)))) {
        x = true;
      }
      if (session == "S6" && (hours >= 17 && mins >= 0) && (hours <= 19)) {
        x = true;
      }
    } else {
      x = false;
    }
    return x;
  }

  String getSessionTime(String session) {
    String time = "";
    switch (session) {
      case "S1":
        time = '8.30 - 10.00';
        break;
      case "S2":
        time = '10.10 - 11.40';
        break;
      case "S3":
        time = '11.50 - 13.20';
        break;
      case "S4":
        time = '13.50 - 15.20';
        break;
      case "S5":
        time = '15.30 - 17.00';
        break;
      case "S6":
        time = '17.10 - 18.40';
        break;
      case "S4'":
        time = '13.30 - 15.00';
        break;
      default:
    }
    return time;
  }

  List<TheDay> getDataFromApi(jsonData, String x) {
    List<TheDay> days = [];
    jsonData['schedule'][x].keys;

    //To run through all days
    for (var currentDay in jsonData['schedule'][x].keys) {
      List<Session> mySessions = [];
      //To run through all the sessions
      int index = 0;
      for (var currentSession in jsonData['schedule'][x][currentDay].keys) {
        index = index + 1;
        String time = getSessionTime(currentSession);

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

  Future<int> getColors(var type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int x = 0;
    if (null != prefs.getInt(type)) {
      x = prefs.getInt(type)!;
    } else {
      switch (type) {
        case "tp":
          x = 0xfffca311;
          break;
        case "td":
          x = 0xfbab3b46;
          break;
        case "c":
          x = 0xff1d7874;
          break;
        default:
      }
      setColor();
    }
    return x;
  }

  setColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("tp", 0xfffca311);
    await prefs.setInt("td", 0xfbab3b46);
    await prefs.setInt("c", 0xff1d7874);
  }

  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  Color? setSpecificColor(type, opacity) {
    if (DynamicTheme.of(context)!.themeId == AppThemes.Light.toInt()) {
      if (type == "TP") {
        return darken(tpcolor, opacity);
      } else if (type == "C") {
        return darken(ccolor, opacity);
      } else if (type == "TD") {
        return darken(tdcolor, opacity);
      }
    } else {
      if (opacity == 1) {
        return const Color(0xff2d333d);
      } else {
        return darken(const Color(0xff2d333d), opacity);
      }
    }
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
            leading: Container(),
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0,
            toolbarHeight: size.height * 0.13,
            //TOPPER CONTENT
            flexibleSpace: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APP NAME AND ICONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          mytext: "Timely",
                          textSize: 25.0,
                          myweight: FontWeight.w900,
                          mycolor: Theme.of(context).primaryColor,
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Selection()));
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).primaryColor,
                              ),
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
                        ),
                      ],
                    ),
                    // GROUP NAME AND REGIME
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          myweight: FontWeight.w600,
                          mytext: widget.majorLbl,
                          textSize: 20.0,
                          mycolor: Theme.of(context).primaryColor,
                        ),
                        MyText(
                          myweight: FontWeight.w600,
                          mytext: getRegime(),
                          textSize: 16.0,
                          mycolor: Theme.of(context).primaryColor,
                        ),
                        /*Row(
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
                        ),*/
                      ],
                    ),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                  ],
                ),
              ),
            ),
            //BOTTOM CONTENT // DAYS
            bottom: TabBar(
              padding: const EdgeInsets.symmetric(horizontal: 00.0),
              onTap: (index) {
                setState(() {
                  selectedDay = index;
                });
              },
              tabs: getDaysWidget(),
              indicatorColor: Colors.blue[700]!,
            ),
          ),
          body: Container(
            padding: const EdgeInsets.only(
              left: 5.0,
            ),
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
