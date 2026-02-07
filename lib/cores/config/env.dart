import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment accessors using `flutter_dotenv`.
/// The app should load the appropriate .env file at startup
/// (for example: `.env.stage` or `.env.prod`).

class EnvStage {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://stage.example.com';
  static String get storageUrl => dotenv.env['STORAGE_URL'] ?? '';
  static String get onesignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
}

class EnvProd {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://api.example.com';
  static String get storageUrl => dotenv.env['STORAGE_URL'] ?? '';
  static String get onesignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
}
