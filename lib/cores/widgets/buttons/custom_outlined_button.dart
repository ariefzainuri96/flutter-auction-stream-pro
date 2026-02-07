import 'package:flutter/material.dart';
import '../../constants/colors.dart';

//ignore: must_be_immutable
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final double widgetSpacing;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final double? height;
  final MainAxisAlignment? alignment;

  ///[onPressed] must be null to disable button
  final Function()? onPressed;

  CustomOutlinedButton({
    super.key,
    this.text = 'ACTION',
    required this.onPressed,
    this.leadingWidget,
    this.trailingWidget,
    this.style,
    this.textStyle,
    this.widgetSpacing = 0,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height ?? 50,
        child: OutlinedButton(
          onPressed: onPressed != null
              ? () {
                  onPressed!();
                }
              : null,
          style: style ??
              OutlinedButton.styleFrom(
                side: BorderSide(
                  width: 1,
                  color: colors.primary,
                ),
                foregroundColor: colors.primary,
                backgroundColor: Colors.black,
              ),
          child: Row(
            mainAxisAlignment: alignment ?? MainAxisAlignment.center,
            children: [
              if (leadingWidget != null)
                Padding(
                  padding: EdgeInsets.only(right: widgetSpacing),
                  child: leadingWidget!,
                ),
              Text(
                text,
                style: textStyle,
              ),
              if (trailingWidget != null)
                Padding(
                  padding: EdgeInsets.only(left: widgetSpacing),
                  child: trailingWidget!,
                ),
            ],
          ),
        ),
      );
}
