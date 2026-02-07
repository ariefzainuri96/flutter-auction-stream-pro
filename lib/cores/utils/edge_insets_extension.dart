import 'package:flutter/material.dart';
import '../widgets/ios_offset.dart';

extension SafeEdgeInsetsExtension on EdgeInsets {
  EdgeInsets get safe => EdgeInsets.fromLTRB(
        left,
        top,
        right,
        bottom + iosBottomOffsetHeight,
      );
}

extension SafeEdgeInsetsNullableExtension on EdgeInsets? {
  EdgeInsets? get safe {
    if (this == null) {
      return EdgeInsets.only(bottom: iosBottomOffsetHeight);
    } else {
      return this!.safe;
    }
  }
}
