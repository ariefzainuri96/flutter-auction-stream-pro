import 'dart:io';

import 'package:dio/dio.dart';

class BadRequestException extends DioException {
  final String? errorMessage;

  BadRequestException({this.errorMessage, required super.requestOptions});

  @override
  String toString() => errorMessage ?? 'Invalid Request';
}

class UnauthorizedException extends DioException {
  UnauthorizedException({required super.requestOptions});

  @override
  String toString() => 'Session has expired';
}

class NotFoundException extends DioException {
  NotFoundException({required super.requestOptions, required super.response});

  @override
  String toString() => 'The requested information could not be found';
}

class InternalServerErrorException extends DioException {
  final String? errorMessage;

  InternalServerErrorException({
    this.errorMessage,
    required super.requestOptions,
  });

  @override
  String toString() =>
      errorMessage ?? 'Unknown error occurred, please try again later.';
}

class NoInternetConnection extends HttpException {
  NoInternetConnection() : super('No Internet Connection!');

  @override
  String toString() => message;
}
