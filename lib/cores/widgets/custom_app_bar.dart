import 'package:flutter/material.dart';
import 'tap_detector.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final bool shouldShowLeading;
  final List<Widget>? actions;
  final Widget? title;
  final Color? backgroundColor;
  final bool isCenterTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.shouldShowLeading = true,
    this.actions,
    this.backgroundColor,
    this.isCenterTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: backgroundColor ?? Colors.white,
        centerTitle: isCenterTitle,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: shouldShowLeading
            ? Center(
                child: TapDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: leading ?? const Icon(Icons.arrow_back),
                ),
              )
            : null,
        actions: [
          const SizedBox(width: 8),
          ...(actions ?? []),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(
            left: shouldShowLeading || isCenterTitle ? 0 : 16,
          ),
          child: title,
        ),
        bottom: bottom,
      );

  @override
  Size get preferredSize =>
      Size(double.maxFinite, 56 + (bottom?.preferredSize.height ?? 0));
}
