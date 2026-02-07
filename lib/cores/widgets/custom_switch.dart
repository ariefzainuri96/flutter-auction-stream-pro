import 'package:flutter/material.dart';

import '../constants/colors.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;
  const CustomSwitch({
    super.key,
    this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          onChanged?.call(!value);
        },
        child: SizedBox(
          width: 42.0,
          height: 25.0,
          child: Stack(
            children: [
              Container(
                width: 42.0,
                height: 16.0,
                margin: EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  color: colors.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                left: value ? 17.0 : 0,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  width: 25.0,
                  height: 25.0,
                  decoration: BoxDecoration(
                    color: value ? colors.primary : Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
