import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ChatBubble extends StatelessWidget {
  final String title;
  final String message;
  final bool isSystem;

  const ChatBubble(
      {super.key,
      required this.title,
      required this.message,
      this.isSystem = false});

  @override
  Widget build(BuildContext context) {
    final bg = isSystem
        ? colors.surfaceDark.withOpacity(0.85)
        : Colors.black.withOpacity(0.4);
    final titleColor = isSystem ? colors.primary : colors.slate300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: titleColor)),
          const SizedBox(height: 4),
          Text(message,
              style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }
}
