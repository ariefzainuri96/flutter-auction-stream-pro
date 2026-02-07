import '../config/env.dart';

class UrlHelper {
  static String get storageUrl {
    const flavor = String.fromEnvironment('ENV');

    if (flavor == 'prod') {
      return EnvProd.storageUrl;
    } else {
      return EnvStage.storageUrl;
    }
  }
}
