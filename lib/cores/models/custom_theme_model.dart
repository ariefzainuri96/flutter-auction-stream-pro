import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CustomThemeModel extends Equatable {
  final ThemeData themeData;
  final String name;

  const CustomThemeModel({
    required this.themeData,
    required this.name,
  });

  @override
  List<Object?> get props => [themeData, name];
}
