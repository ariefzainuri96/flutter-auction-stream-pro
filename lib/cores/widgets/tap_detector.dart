import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TapDetector extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final int? debounceMs;

  TapDetector({
    super.key,
    required this.onTap,
    required this.child,
    this.debounceMs,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap?.call();
        },
        child: child,
      );
}
