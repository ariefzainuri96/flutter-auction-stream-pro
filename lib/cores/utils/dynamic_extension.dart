bool? checkBoolValue(dynamic value) {
  if (value is bool) {
    return value;
  } else if (value is String) {
    switch (value) {
      case '1':
        return true;
      case '0':
        return false;
      default:
        return null;
    }
  } else {
    return null;
  }
}
