import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AvatarBadge extends StatelessWidget {
  final double size;
  final Widget? child;
  final VoidCallback? onEdit;

  const AvatarBadge({
    super.key,
    this.size = 80,
    this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.surfaceDark,
            border: Border.all(color: colors.surfaceBorder, width: 2),
            shape: BoxShape.circle,
          ),
          child: child ??
              const Icon(Icons.person_outline,
                  color: Color(0xFF64748B), size: 36),
        ),
        if (onEdit != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.backgroundDark, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }
}
