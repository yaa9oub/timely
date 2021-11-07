import 'package:flutter/material.dart';
import 'package:timely/widgets/text.dart';

class DayWidget extends StatelessWidget {
  final String mytext;
  final Color borderColors;
  final bool selected;
  const DayWidget({
    Key? key,
    required this.mytext,
    required this.borderColors,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 7,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: selected
              ? Theme.of(context).cardColor
              : Theme.of(context).primaryColorLight,
          /*boxShadow: [
            BoxShadow(
              color: borderColors,
              blurRadius: 0.0,
              offset: const Offset(
                3.0,
                3.0,
              ),
            ),
          ],*/
        ),
        child: Center(
          child: MyText(
            myweight: selected ? FontWeight.w900 : FontWeight.bold,
            mytext: mytext,
            textSize: 18,
            mycolor: selected
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
