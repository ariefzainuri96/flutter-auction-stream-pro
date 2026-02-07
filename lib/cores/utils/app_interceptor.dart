import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../routers/router_constant.dart';
import '../../hive/hive_helper.dart';
import 'navigation_service.dart';
import 'print_helper.dart';
import 'service_helper.dart';

class AppInterceptor extends Interceptor {
  final Dio dio;

  AppInterceptor(this.dio);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('==== Response INTERCEPTOR START ====');
      debugPrint('uri: ${response.requestOptions.path}\n');
      debugPrint('params: ${response.requestOptions.extra}\n');
      printFullText('response: ${response.data}\n');
      printFullText('body: ${response.requestOptions.data}');
      debugPrint('==== Response INTERCEPTOR END ====');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('==== ERROR INTERCEPTOR START ====');
      print('Error: $err');
      print('uri: ${err.requestOptions.uri}');
      print('path: ${err.requestOptions.path}');
      print('body: ${err.requestOptions.data}');
      // print('body: ${err.requestOptions.data}');
      print('message: ${err.message}');
      printFullText('response: ${err.response}');
      print('error status code ${err.response?.statusCode}');
      // print('body: ${printPrettyJson(err.requestOptions.data)}');
      print('==== ERROR INTERCEPTOR END ====');
    }

    DioException? error;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        break;
      case DioExceptionType.badResponse:
        String? message;

        if (err.response?.data is Map<String, dynamic>) {
          message = err.response?.data['error'];
        }

        if ((err.response?.statusCode == 401 ||
                (message ?? '').contains('Unauthenticated')) &&
            NavigationService.currentRouteName != Routes.login) {
          error = UnauthorizedException(requestOptions: err.requestOptions);
          HiveHelper.clearData();
          NavigationService.pushNamedAndRemoveAll(
            Routes.login,
          );
        } else if (err.response?.statusCode == 404) {
          error = NotFoundException(
            requestOptions: err.requestOptions,
            response: err.response,
          );
        } else if (err.response?.statusCode == 500) {
          error = InternalServerErrorException(
            errorMessage: message,
            requestOptions: err.requestOptions,
          );
        } else {
          error = BadRequestException(
            errorMessage: message,
            requestOptions: err.requestOptions,
          );
        }
        break;
      default:
        break;
    }

    if (error != null) {
      throw error;
    }

    return handler.next(err);
  }
}
