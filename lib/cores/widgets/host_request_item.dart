import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HostRequestItem extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String reputation;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const HostRequestItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.reputation,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceBorder.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFF90A4CB)),
                    const SizedBox(width: 6),
                    Text(reputation,
                        style: const TextStyle(
                            color: Color(0xFF90A4CB), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              IconButton(
                onPressed: onReject,
                icon: const Icon(Icons.close, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onApprove,
                icon: const Icon(Icons.check, color: Color(0xFF10B981)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
