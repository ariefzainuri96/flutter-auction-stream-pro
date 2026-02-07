import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Shared custom input field used across features
class SharedInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool isMonospaced;

  const SharedInputField({
    super.key,
    required this.label,
    required this.placeholder,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.isMonospaced = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.slate300,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceDark,
            border: Border.all(
              color: colors.surfaceBorder,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: isMonospaced ? 'monospace' : null,
              letterSpacing: isMonospaced ? 1.2 : null,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: colors.slate500,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: colors.slate500,
                      size: 20,
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: colors.slate500,
                      size: 20,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: prefixIcon != null ? 0 : 12,
                vertical: 12,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colors.primary,
                  width: 1,
                ),
              ),
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
