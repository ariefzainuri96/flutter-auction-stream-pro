import 'package:flutter/material.dart';

class TextFormModel {
  final controller = TextEditingController();
  bool Function(String)? validator;

  String get text => controller.text;
  set text(String value) => controller.text = value;

  bool get isValid => validator?.call(text) ?? true;

  TextFormModel({this.validator});
}
