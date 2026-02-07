import 'package:flutter/material.dart';
import '../constants/text_theme.dart';
import 'custom_app_bar.dart';

class TextAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final bool shouldShowLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool isCenterTitle;
  final Widget? customTitle;
  final bool showCustomTitle;
  final PreferredSizeWidget? bottom;

  const TextAppBar({
    super.key,
    required this.title,
    this.leading,
    this.shouldShowLeading = true,
    this.actions,
    this.backgroundColor,
    this.isCenterTitle = true,
    this.customTitle,
    this.showCustomTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) => CustomAppBar(
        leading: leading,
        shouldShowLeading: shouldShowLeading,
        actions: actions,
        title: showCustomTitle && customTitle != null
            ? customTitle
            : Text(title, style: textTheme.font18Bold),
        backgroundColor: backgroundColor,
        isCenterTitle: isCenterTitle,
        bottom: bottom,
      );

  @override
  Size get preferredSize =>
      Size(double.maxFinite, 56.0 + (bottom?.preferredSize.height ?? 0));
}
