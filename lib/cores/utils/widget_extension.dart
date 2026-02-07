import 'package:flutter/widgets.dart';

extension WidgetExtension on Widget {
  Widget withPadding(EdgeInsets padding) => Padding(
        padding: padding,
        child: this,
      );

  Widget withMargin(EdgeInsets margin) => Container(
        margin: margin,
        child: this,
      );

  // Optional shortcuts for common padding use-cases
  Widget padAll(double value) => withPadding(EdgeInsets.all(value));
  Widget marAll(double value) => withMargin(EdgeInsets.all(value));

  Widget padSymmetric({double horizontal = 0, double vertical = 0}) =>
      withPadding(
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      );
  Widget marSymmetric({double horizontal = 0, double vertical = 0}) =>
      withMargin(
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      );

  Widget padOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      withPadding(
        EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
      );

  Widget marOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      withMargin(
        EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
      );
}
