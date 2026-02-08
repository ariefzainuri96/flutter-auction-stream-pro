import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/base/base_service.dart';
import '../model/login_request_model.dart';
import '../model/login_response/login_response.dart';

final loginService = Provider((ref) => LoginService());

class LoginService extends BaseService {
  Future<LoginResponse?> login(LoginRequestModel request) async {
    try {
      // Response? response = await post(
      //   url: 'loginapi',
      //   data: {
      //     'username': request.username,
      //     'password': request.password,
      //     'fcm_token': '123',
      //   },
      // );

      // if (response?.statusCode != 200) return null;

      // return LoginResponse.fromJson(jsonEncode(response?.data));

      // Simulated response for demonstration purposes
      await Future.delayed(const Duration(milliseconds: 500));

      final simulatedResponse = {
        'user': {
          'id': 1,
          'username': request.username,
          'role': 'user',
        },
        'token': 'simulated_jwt_token',
      };

      return LoginResponse.fromJson(jsonEncode(simulatedResponse));
    } catch (e) {
      return null;
    }
  }
}
