import 'dart:convert';
import 'package:flutter/foundation.dart';

void printFullText(String text) {
  final pattern = RegExp('.{1,800}');
  for (final match in pattern.allMatches(text)) {
    if (kDebugMode) {
      print(match.group(0));
    }
  }
}

printPrettyJson(dynamic data) {
  const encoder = JsonEncoder.withIndent('  ');
  printFullText(encoder.convert(data));
}
