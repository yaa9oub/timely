import 'package:flutter/material.dart';
import 'package:timely/widgets/text.dart';

class SessionWidget extends StatelessWidget {
  final String session, time;
  const SessionWidget({
    Key? key,
    required this.session,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7.0),
          decoration: BoxDecoration(
              color: Colors.blue[800]!,
              borderRadius: BorderRadius.circular(5.0)),
          child: MyText(
            myweight: FontWeight.bold,
            mytext: session,
            textSize: 16,
            mycolor: Colors.white,
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        MyText(
          myweight: FontWeight.bold,
          mytext: time,
          textSize: 14.5,
          mycolor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
