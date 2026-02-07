import 'package:flutter/material.dart';
import '../../constants/colors.dart';

//ignore: must_be_immutable
class Button extends StatelessWidget {
  final String text;
  final double widgetSpacing;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final ButtonStyle? style; // want to set button color to become yellow
  final double? width;
  final double? height;
  final MainAxisAlignment? alignment;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool nullHeight;

  ///[onPressed] must be null to disable button
  final void Function()? onPressed;

  Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingWidget,
    this.trailingWidget,
    this.style,
    this.widgetSpacing = 0,
    this.width,
    this.height,
    this.alignment,
    this.textStyle,
    this.isLoading = false,
    this.nullHeight = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: nullHeight ? null : height ?? 50,
        child: ElevatedButton(
          onPressed: (onPressed != null && !isLoading)
              ? () {
                  if (isLoading) return;

                  onPressed!();
                }
              : null,
          style: style ??
              ElevatedButton.styleFrom(
                backgroundColor: colors.primary, // set your yellow color here
                foregroundColor: Colors.white,
                disabledBackgroundColor: colors.disable,
                disabledForegroundColor: colors.grey3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          child: Row(
            mainAxisAlignment: alignment ?? MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
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
