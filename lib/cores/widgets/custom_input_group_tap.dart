import 'package:flutter/widgets.dart';
import '../constants/colors.dart';
import '../constants/text_theme.dart';

class CustomInputGroupTap extends StatelessWidget {
  final String label;
  final bool showAsterisk;
  final Widget groupTap;

  const CustomInputGroupTap({
    super.key,
    required this.label,
    required this.showAsterisk,
    required this.groupTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: textTheme.font16Medium,
                  ),
                  if (showAsterisk)
                    TextSpan(
                      text: '*',
                      style: textTheme.font16Medium.copyWith(
                        color: colors.red1,
                      ),
                    ),
                ],
              ),
            ),
          if (label.isNotEmpty) SizedBox(height: 6.0),
          groupTap,
        ],
      );
}
