import '../utils/string_extension.dart';

enum Flavor { stage, prod }

convertToFlavorEnum(String value) {
  switch (value) {
    case 'prod':
      return Flavor.prod;
    default:
      return Flavor.stage;
  }
}

class FlavorValues {
  final String baseUrl;

  FlavorValues({required this.baseUrl});

  String token = '';
  String role = '';
  String password = '';
  int userId = 0;
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final FlavorValues values;
  static FlavorConfig? _instance;

  static FlavorConfig? get instance => _instance;

  FlavorConfig._internal(this.flavor, this.name, this.values);

  factory FlavorConfig({required Flavor flavor, required FlavorValues values}) {
    _instance ??=
        FlavorConfig._internal(flavor, flavor.toString().enumName(), values);
    return _instance!;
  }
}
