import '../../../cores/utils/string_extension.dart';

class LoginRequestModel {
  String? username;
  String? password;

  LoginRequestModel({this.username, this.password});

  LoginRequestModel copyWith({String? username, String? password}) =>
      LoginRequestModel(
        username: username ?? this.username,
        password: password ?? this.password,
      );

  bool isFilled() => username.isNotNullOrEmpty && password.isNotNullOrEmpty;
}
