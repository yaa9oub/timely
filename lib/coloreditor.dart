import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/calendar.dart';
import 'package:timely/widgets/text.dart';

class ColorEditor extends StatefulWidget {
  final String majorId, majorLbl;
  final bool grp;
  const ColorEditor(
      {Key? key,
      required this.majorId,
      required this.majorLbl,
      required this.grp})
      : super(key: key);

  @override
  _ColorEditorState createState() => _ColorEditorState();
}

class _ColorEditorState extends State<ColorEditor> {
  Color tpcolor = Colors.red, tdcolor = Colors.blue, ccolor = Colors.green;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Calendar(
                        grp: true,
                        majorId: widget.majorId,
                        majorLbl: widget.majorLbl,
                      )));
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Container(
          width: size.width,
          height: size.height,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.8,
                  child: const MyText(
                      mytext: "Customize your colors",
                      textSize: 50.0,
                      myweight: FontWeight.w600,
                      mycolor: Colors.black),
                ),
                SizedBox(
                  height: size.height * 0.1,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      )
                    ],
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  width: size.width * 0.8,
                  height: size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "TP Color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 1, "TPs");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: tpcolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "TD Color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 2, "TDs");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: tdcolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText(
                              mytext: "Cours Color",
                              textSize: 20.0,
                              myweight: FontWeight.bold,
                              mycolor: Theme.of(context).primaryColor),
                          InkWell(
                            onTap: () {
                              pickColor(context, 3, "Courses");
                            },
                            child: Container(
                              width: size.width * 0.1,
                              height: size.width * 0.1,
                              decoration: BoxDecoration(
                                color: ccolor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildColorPicker1() => BlockPicker(
      pickerColor: tpcolor,
      onColorChanged: (color) {
        setState(() => this.tpcolor = color);
      });

  Widget buildColorPicker2() => BlockPicker(
      pickerColor: tdcolor,
      onColorChanged: (color) => setState(() => this.tdcolor = color));

  Widget buildColorPicker3() => BlockPicker(
      pickerColor: ccolor,
      onColorChanged: (color) => setState(() => this.ccolor = color));

  void pickColor(BuildContext context, int x, String type) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: MyText(
                mytext: "Pick A Color for your " + type,
                textSize: 22.0,
                myweight: FontWeight.normal,
                mycolor: Colors.black),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                x == 1
                    ? buildColorPicker1()
                    : x == 2
                        ? buildColorPicker2()
                        : buildColorPicker3(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        setColor();
                        final snackBar = SnackBar(
                          content: const Text('Color Saved!'),
                          action: SnackBarAction(
                            label: 'Ok',
                            onPressed: () {},
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(color: Colors.grey, width: 2.0)),
                        child: const MyText(
                            mytext: "Select",
                            textSize: 22.0,
                            myweight: FontWeight.normal,
                            mycolor: Colors.black),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.0),
                            border: Border.all(color: Colors.grey, width: 2.0)),
                        child: const MyText(
                            mytext: "Cancel",
                            textSize: 22.0,
                            myweight: FontWeight.normal,
                            mycolor: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  setColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("tp", tpcolor.value);
    await prefs.setInt("td", tdcolor.value);
    await prefs.setInt("c", ccolor.value);
  }

  Future<int> getColors(var type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int x = 0;
    if (null != prefs.getInt(type)) {
      x = prefs.getInt(type)!;
    }
    return x;
  }
}
