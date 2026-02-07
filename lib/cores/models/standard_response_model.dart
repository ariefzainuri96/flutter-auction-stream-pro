// To parse this JSON data, do
//
//     final standardResponseModel = standardResponseModelFromJson(jsonString);

import 'dart:convert';

StandardResponseModel<T> standardResponseModelFromJson<T>(
  String str,
  T Function(Object? json) fromJsonT,
) =>
    StandardResponseModel<T>.fromJson(json.decode(str), fromJsonT);

String standardResponseModelToJson<T>(
  StandardResponseModel<T> data,
  Object? Function(T value) toJsonT,
) =>
    json.encode(data.toJson(toJsonT));

class StandardResponseModel<T> {
  final int? code;
  final String? errorCode;
  final String? message;
  final T? data;

  StandardResponseModel({
    this.code,
    this.errorCode,
    this.message,
    this.data,
  });

  factory StandardResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      StandardResponseModel<T>(
        code: json['code'],
        errorCode: json['error_code'],
        message: json['message'],
        data: json['data'] != null ? fromJsonT(json['data']) : null,
      );

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) => {
        'code': code,
        'error_code': errorCode,
        'message': message,
        'data': data != null ? toJsonT(data as T) : null,
      };
}
