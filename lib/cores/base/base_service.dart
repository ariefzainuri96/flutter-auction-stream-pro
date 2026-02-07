import 'dart:io';
import 'package:dio/dio.dart';
import '../config/flavor_config.dart';
import '../utils/app_interceptor.dart';
import '../utils/service_helper.dart';

const Duration _defaultTimeout = Duration(minutes: 1); //60 seconds

class BaseService {
  final Dio _dio = Dio();

  BaseService() {
    _dio.interceptors.add(AppInterceptor(_dio));
  }

  static Future<Map<String, String>> get header async {
    // final deviceInfo = DeviceInfoPlugin();
    // PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String platform = Platform.isAndroid ? 'android' : 'ios';
    // String? deviceId = Platform.isAndroid
    //     ? (await deviceInfo.androidInfo).id
    //     : (await deviceInfo.iosInfo).identifierForVendor;
    String token = FlavorConfig.instance?.values.token ?? '';
    // String userId = FlavorConfig.instance?.values.userId ?? '';

    Map<String, String> header = {
      // 'Device-Type': platform,
      // 'Device-Id': deviceId ?? '',
      // 'Version-ResponseCode': packageInfo.version.replaceAll('-dev', ''),
      // 'AppName': 'nfl_stadeo',
      'Authorization': 'Bearer $token',
      // 'UserId': userId,
    };

    return header;
  }

  get({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    await _tokenCheck();
    if (!await _isInternetAvailable()) {
      throw NoInternetConnection();
    }
    Map<String, dynamic> header = await BaseService.header;
    final Response<dynamic> response = await _dio.get(
      '${FlavorConfig.instance?.values.baseUrl}$url',
      queryParameters: params,
      options: Options(
        headers: {
          ...header,
          ...?headers,
        },
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
      data: data,
    );
    return response;
  }

  getWithProgress({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
    void Function(int count, int total)? onReceiveProgress,
  }) async {
    await _tokenCheck();
    if (!await _isInternetAvailable()) {
      throw NoInternetConnection();
    }
    Map<String, dynamic> header = await BaseService.header;
    final Response<dynamic> response = await _dio.get(
      '${FlavorConfig.instance?.values.baseUrl}$url',
      queryParameters: params,
      options: Options(
        headers: {
          ...header,
          ...?headers,
        },
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
      onReceiveProgress: onReceiveProgress,
      data: data,
    );
    return response;
  }

  post({
    required String url,
    Map<String, String>? headers,
    dynamic data,
  }) async {
    await _tokenCheck();
    if (!await _isInternetAvailable()) {
      throw NoInternetConnection();
    }

    Map<String, dynamic> header = await BaseService.header;

    final Response<dynamic> response = await _dio.post(
      '${FlavorConfig.instance?.values.baseUrl}$url',
      options: Options(
        headers: {
          ...header,
          ...?headers,
        },
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
      data: data,
    );
    return response;
  }

  delete({
    required String url,
    Map<String, String>? headers,
  }) async {
    await _tokenCheck();
    if (!await _isInternetAvailable()) {
      throw NoInternetConnection();
    }

    Map<String, dynamic> header = await BaseService.header;

    final Response<dynamic> response = await _dio.delete(
      '${FlavorConfig.instance?.values.baseUrl}$url',
      options: Options(
        headers: {
          ...header,
          ...?headers,
        },
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
    );
    return response;
  }

  put({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    await _tokenCheck();
    if (!await _isInternetAvailable()) {
      throw NoInternetConnection();
    }
    Map<String, dynamic> header = await BaseService.header;
    final Response<dynamic> response = await _dio.put(
      '${FlavorConfig.instance?.values.baseUrl}$url',
      options: Options(
        headers: {
          ...header,
          ...?headers,
        },
        receiveTimeout: _defaultTimeout,
        sendTimeout: _defaultTimeout,
      ),
      data: data ?? formData,
    );
    return response;
  }

  _tokenCheck() async {
    //  TODO: check and renew token
  }

  Future<bool> _isInternetAvailable() async {
    try {
      final foo = await InternetAddress.lookup('google.com');
      return foo.isNotEmpty && foo[0].rawAddress.isNotEmpty ? true : false;
    } catch (e) {
      return false;
    }
  }
}
