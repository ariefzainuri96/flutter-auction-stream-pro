import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_theme.dart';
import '../utils/navigation_service.dart';
import '../utils/widget_extension.dart';
import 'buttons/button.dart';
import 'tap_detector.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final Function() onConfirmClick;
  final String confirmText;
  final bool hideBatalButton;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onConfirmClick,
    required this.confirmText,
    this.hideBatalButton = false,
  });

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: const TextStyle(),
                child: Text(
                  title,
                  style: textTheme.font18Medium,
                ),
              ),
              DefaultTextStyle(
                style: const TextStyle(),
                child: Text(
                  description,
                  style: textTheme.font16Reguler,
                ),
              ).padOnly(top: 10, bottom: 16),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    if (!hideBatalButton)
                      TapDetector(
                        onTap: () {
                          NavigationService.pop();
                        },
                        child: Text(
                          'Batal',
                          style: textTheme.font14Bold
                              .copyWith(decoration: TextDecoration.none),
                        ),
                      ),
                    Button(
                      text: confirmText,
                      height: 40,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: colors.primary,
                      ),
                      textStyle:
                          textTheme.font14Bold.copyWith(color: Colors.white),
                      onPressed: onConfirmClick,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
