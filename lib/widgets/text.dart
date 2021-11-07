import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String mytext;
  final double textSize;
  final FontWeight myweight;
  final Color mycolor;
  const MyText(
      {Key? key,
      required this.mytext,
      required this.textSize,
      required this.myweight,
      required this.mycolor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      mytext,
      style: TextStyle(
        fontFamily: 'Comforta',
        fontWeight: myweight,
        fontSize: textSize,
        color: mycolor,
      ),
    );
  }
}
