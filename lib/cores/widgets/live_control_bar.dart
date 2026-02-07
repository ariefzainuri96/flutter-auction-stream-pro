import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'icon_circle_button.dart';
import 'bid_button.dart';

class LiveControlBar extends StatelessWidget {
  final VoidCallback? onLike;
  final VoidCallback? onSpeak;
  final VoidCallback? onBid;

  const LiveControlBar({super.key, this.onLike, this.onSpeak, this.onBid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconCircleButton(
            icon: Icons.favorite,
            onPressed: onLike,
            backgroundColor: Colors.white.withOpacity(0.08)),
        const Spacer(),
        Column(
          children: [
            GestureDetector(
              onTap: onSpeak,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08), width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: colors.primary.withOpacity(0.25),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 6),
                  Text('Speak',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: 160,
          child:
              BidButton(label: 'Quick Bid', amountLabel: '+\$10', onTap: onBid),
        ),
      ],
    );
  }
}
