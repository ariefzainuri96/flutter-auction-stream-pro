import 'package:flutter/material.dart';

import 'navigation_service.dart';

double get statusBarHeight =>
    MediaQuery.of(NavigationService.globalContext).viewPadding.top;

double get getScreenWidth =>
    MediaQuery.sizeOf(NavigationService.globalContext).width;

double get getScreenHeight =>
    MediaQuery.sizeOf(NavigationService.globalContext).height;

double get getCenterScreen =>
    (MediaQuery.sizeOf(NavigationService.globalContext).height -
        56.0 -
        MediaQuery.of(NavigationService.globalContext).padding.top) /
    2;

double getCenterScreenWithTabbar(PreferredSizeWidget widget) =>
    (MediaQuery.sizeOf(NavigationService.globalContext).height -
        56.0 -
        widget.preferredSize.height -
        MediaQuery.of(NavigationService.globalContext).padding.top) /
    2;

double getCenterScreenWithWidget(double size) =>
    (MediaQuery.sizeOf(NavigationService.globalContext).height -
        56.0 -
        size -
        MediaQuery.of(NavigationService.globalContext).padding.top) /
    2;

double getTextHeight(
  String text,
  TextStyle style,
  double maxWidth,
  int? maxLines,
) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  return textPainter.height;
}

double get bottomSafePadding {
  final mediaQuery = MediaQuery.of(NavigationService.globalContext);

  return mediaQuery.viewInsets.bottom > 0
      ? mediaQuery.viewInsets.bottom
      : mediaQuery.viewPadding.bottom;
}
