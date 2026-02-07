import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SharedToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SharedToggleSwitch(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? colors.primary : const Color(0xFF374151),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ),
    );
}
