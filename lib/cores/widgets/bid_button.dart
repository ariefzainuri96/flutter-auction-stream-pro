import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BidButton extends StatelessWidget {
  final String label;
  final String amountLabel;
  final VoidCallback? onTap;

  const BidButton(
      {super.key, required this.label, required this.amountLabel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: colors.accent.withOpacity(0.4), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                    style: const TextStyle(
                        color: Color(0xFF064E3B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                Text(amountLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ],
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
