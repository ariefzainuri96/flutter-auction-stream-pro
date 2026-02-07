import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'toggle_switch.dart';

class HardwareCheckRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const HardwareCheckRow(
      {super.key,
      required this.label,
      required this.icon,
      required this.enabled,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text('Device check',
                    style: TextStyle(color: colors.slate400, fontSize: 12)),
              ],
            ),
          ],
        ),
        SharedToggleSwitch(value: enabled, onChanged: onChanged),
      ],
    );
  }
}
