extension BoolIntExtension on bool? {
  int toInt() => this == true ? 1 : 0;
}

extension IntBoolExtension on int? {
  bool toBool() => this == 1;
}
