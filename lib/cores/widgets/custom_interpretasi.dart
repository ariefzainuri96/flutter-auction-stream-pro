import 'package:flutter/material.dart';
import '../constants/text_theme.dart';

class CustomInterpretasi extends StatelessWidget {
  final String interpretasi;
  final String? value;
  final Color interpretasiColor;

  const CustomInterpretasi({
    super.key,
    required this.interpretasi,
    required this.interpretasiColor,
    this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: interpretasiColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: RichText(
          text: TextSpan(
            text: interpretasi,
            style: textTheme.font14Bold,
            children: [
              if (value != null) ...[
                TextSpan(
                  text: ':',
                  style: textTheme.font14Bold,
                ),
                TextSpan(
                  text: ' $value',
                  style: textTheme.font14Medium,
                ),
              ],
            ],
          ),
        ),
      );
}
