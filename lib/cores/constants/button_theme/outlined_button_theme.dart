import 'package:flutter/material.dart';
import '../colors.dart';
import '../text_theme.dart';

final outlinedButtonTheme = OutlinedButtonThemeData(
  style: ButtonStyle(
    padding: WidgetStateProperty.resolveWith<EdgeInsets>(
      (states) => EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
    ),
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) => Colors.black,
    ),
    side: WidgetStateProperty.resolveWith(
      (states) => BorderSide(
        color: states.contains(WidgetState.disabled)
            ? colors.disable
            : states.contains(WidgetState.pressed)
                ? colors.disable
                : colors.primary,
        width: 1,
      ),
    ),
    shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
      (_) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disable;
        } else if (states.contains(WidgetState.pressed)) {
          return colors.primary;
        }
        return colors.primary;
      },
    ),
    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) => textTheme.font16Bold,
    ),
    elevation: WidgetStateProperty.resolveWith<double>(
      (states) => 0,
    ),
  ),
);
