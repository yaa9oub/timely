import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timely/widgets/text.dart';

class DescriptionWidget extends StatefulWidget {
  final String desc, type, classroom, regime;
  final Color borderColor;
  const DescriptionWidget(
      {Key? key,
      required this.desc,
      required this.borderColor,
      required this.type,
      required this.classroom,
      required this.regime})
      : super(key: key);

  @override
  State<DescriptionWidget> createState() => _DescriptionWidgetState();
}

class _DescriptionWidgetState extends State<DescriptionWidget> {
  Color lblColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
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

  Future<int> getColors(var type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int x = 0;
    if (null != prefs.getInt(type)) {
      x = prefs.getInt(type)!;
    }
    return x;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            height: MediaQuery.of(context).size.height * 0.13,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              //borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              color: Theme.of(context).primaryColorLight,
              /*boxShadow: [
                BoxShadow(
                  color: widget.borderColor,
                  blurRadius: 0.0, // soften the shadow
                  offset: const Offset(
                    3.0, // Move to right 10  horizontally
                    3.0, // Move to bottom 5 Vertically
                  ),
                ),
              ],*/
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor == Colors.white
                          ? (widget.type == "TP"
                              ? tpcolor
                              : widget.type == "C"
                                  ? ccolor
                                  : widget.type == "TD"
                                      ? tdcolor
                                      : Colors.white)
                          : Colors.grey[900],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15.0))),
                  child: MyText(
                    mytext: widget.desc.length > 50
                        ? widget.desc.substring(5, 30) + ". . ."
                        : widget.desc.substring(5, widget.desc.length),
                    textSize: 16,
                    myweight: FontWeight.bold,
                    mycolor: Theme.of(context).backgroundColor == Colors.white
                        ? Theme.of(context).primaryColorDark
                        : Theme.of(context).primaryColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      mytext: widget.classroom,
                      textSize: 15,
                      myweight: FontWeight.normal,
                      mycolor: Theme.of(context).primaryColor,
                    ),
                    MyText(
                      mytext: widget.type,
                      textSize: 15,
                      myweight: FontWeight.normal,
                      mycolor: Theme.of(context).primaryColor,
                    ),
                    MyText(
                      mytext: widget.regime,
                      textSize: 15,
                      myweight: FontWeight.normal,
                      mycolor: Theme.of(context).primaryColor,
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
