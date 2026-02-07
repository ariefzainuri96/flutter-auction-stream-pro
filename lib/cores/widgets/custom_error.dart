import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_theme.dart';

class CustomError extends StatelessWidget {
  final String? message;
  final bool showRetry;
  final Function()? onRetry;

  const CustomError({
    super.key,
    this.onRetry,
    this.message,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          text: message ?? 'Terjadi kesalahan, ',
          style: textTheme.font14Medium,
          children: [
            if (showRetry) ...[
              TextSpan(
                text: 'Ulangi?',
                recognizer: TapGestureRecognizer()..onTap = onRetry,
                style: TextStyle(
                  color: colors.primary,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      );
}
