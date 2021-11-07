import 'package:flutter/material.dart';
import 'package:timely/widgets/text.dart';

class SessionWidget extends StatelessWidget {
  final String session, time;
  final Color borderColor;
  const SessionWidget(
      {Key? key,
      required this.session,
      required this.time,
      required this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.20,
        height: MediaQuery.of(context).size.height * 0.13,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          //borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          //color: Theme.of(context).primaryColorLight,
          /*boxShadow: [
            BoxShadow(
              color: borderColor,
              blurRadius: 0.0,
              offset: const Offset(
                3.0,
                3.0,
              ),
            ),
          ],*/
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MyText(
                  myweight: FontWeight.bold,
                  mytext: session,
                  textSize: 16,
                  mycolor: Theme.of(context).primaryColor,
                ),
                MyText(
                  myweight: FontWeight.bold,
                  mytext: time,
                  textSize: 12.5,
                  mycolor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
