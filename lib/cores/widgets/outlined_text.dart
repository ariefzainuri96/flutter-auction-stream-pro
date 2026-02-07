import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;
  final Color fillColor;

  const OutlinedText({
    super.key,
    required this.text,
    required this.style,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1.5,
    this.fillColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Text(
            text,
            style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
          // Filled text
          Text(
            text,
            style: style.copyWith(color: fillColor),
          ),
        ],
      );
}
