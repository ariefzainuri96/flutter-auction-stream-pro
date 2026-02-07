import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'tap_detector.dart';

class CustomRadio<T> extends StatelessWidget {
  final T value;
  final bool selected;
  final Function(T) onChange;
  final Widget? child;

  const CustomRadio({
    super.key,
    required this.value,
    required this.selected,
    required this.onChange,
    this.child,
  });

  @override
  Widget build(BuildContext context) => TapDetector(
        onTap: () => onChange(value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.primary : Colors.transparent,
                  ),
                ),
              ),
            ),
            if (child != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: child!,
                ),
              ),
          ],
        ),
      );
}
