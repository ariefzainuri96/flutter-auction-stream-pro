import 'package:flutter/material.dart';

class CustomStrokeText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final double strokeWidth;
  final Color strokeColor;

  const CustomStrokeText({
    super.key,
    required this.text,
    required this.textStyle,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          // Stroked text as border.
          Text(
            text,
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
          // Solid text as fill.
          Text(
            text,
            style: textStyle,
          ),
        ],
      );
}
