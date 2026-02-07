import 'dart:ui';

extension HexColorExtension on String? {
  Color? toColor() {
    if (this == null) return null;
    String hex = this!.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add full opacity
    } else if (hex.length != 8) {
      return null; // Invalid format
    }

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }
}
