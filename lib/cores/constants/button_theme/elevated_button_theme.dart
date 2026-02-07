import 'package:flutter/material.dart';
import '../colors.dart';
import '../text_theme.dart';

final elevatedButtonTheme = ElevatedButtonThemeData(
  style: ButtonStyle(
    padding: WidgetStateProperty.resolveWith<EdgeInsets>(
      (states) => EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
    ),
    shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
      (_) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100.0),
      ),
    ),
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.disable;
        }
        return colors.primary;
      },
    ),
    foregroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) => Colors.black,
    ),
    textStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) => textTheme.font16Bold,
    ),
    elevation: WidgetStateProperty.resolveWith<double>(
      (states) => 0,
    ),
    minimumSize: WidgetStateProperty.resolveWith<Size>(
      (states) => const Size(double.minPositive, double.minPositive),
    ),
  ),
);
