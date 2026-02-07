import 'package:flutter/material.dart';
import '../constants/colors.dart';

class LiveStatusCard extends StatelessWidget {
  final String avatarUrl;
  final String highestBid;
  final bool isLive;

  const LiveStatusCard({
    super.key,
    required this.avatarUrl,
    required this.highestBid,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.transparent,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.backgroundDark, width: 2),
                  ),
                  child: const Icon(Icons.gavel, color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLive ? Colors.redAccent : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colors.red500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Highest Bid: ',
                      style: TextStyle(color: colors.slate400, fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(highestBid,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
