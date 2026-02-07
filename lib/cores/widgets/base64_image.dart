import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class Base64Image extends StatelessWidget {
  final String base64String;
  final double? size;
  final double? width;
  final double? height;

  const Base64Image(
    this.base64String, {
    super.key,
    this.size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // decode base64 to bytes
    Uint8List bytes = base64Decode(base64String);

    return Image.memory(
      width: width ?? size ?? 40,
      height: height ?? size ?? 40,
      bytes,
      fit: BoxFit.fill, // you can change to BoxFit.contain/fitWidth etc.
    );
  }
}
