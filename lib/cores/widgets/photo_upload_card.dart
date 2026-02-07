import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PhotoUploadCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PhotoUploadCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.surfaceBorder),
          color: colors.surfaceDark.withOpacity(0.6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.15),
                  shape: BoxShape.circle),
              child: Icon(Icons.add_a_photo, color: colors.primary, size: 32),
            ),
            const SizedBox(height: 12),
            const Text('Add Item Photo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Tap to upload or take a picture',
                style: TextStyle(color: colors.slate400, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
