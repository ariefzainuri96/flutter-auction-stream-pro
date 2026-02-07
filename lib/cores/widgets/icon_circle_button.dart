import 'package:flutter/material.dart';

class IconCircleButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const IconCircleButton({
    super.key,
    required this.icon,
    this.size = 44,
    this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }
}
