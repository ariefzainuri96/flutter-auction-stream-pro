import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cores/constants/enums/page_state.dart';
import '../../../hive/entity/auth_data.dart';
import '../../../cores/routers/router_constant.dart';
import '../../../hive/hive_helper.dart';
import '../../../cores/utils/navigation_service.dart';
import '../model/login_request_model.dart';
import '../services/login_service.dart';

final loginProvider =
    NotifierProvider.autoDispose<LoginNotifier, LoginNotifierData>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<LoginNotifierData> {
  @override
  LoginNotifierData build() => LoginNotifierData(
        request: LoginRequestModel(),
        loginState: PageState.initial,
      );

  Future<void> login() async {
    state = state.copyWith(loginState: PageState.loading);
    final data = await ref.read(loginService).login(state.request);
    state = state.copyWith(
      loginState: data != null ? PageState.success : PageState.error,
    );

    if (data == null) {
      debugPrint('Gagal melakukan login, Username/Password salah!');
      return;
    }

    await HiveHelper.saveUserToBox(
      AuthData(
        userId: data.user?.id ?? 0,
        token: data.token ?? '',
        role: data.user?.role ?? '',
        password: state.request.password ?? '',
      ),
    );

    NavigationService.pushNamedAndRemoveAll(Routes.downloadData);
  }

  void updateRequest(LoginRequestModel value) {
    state = state.copyWith(request: value);
  }
}

class LoginNotifierData {
  LoginRequestModel request;
  PageState loginState;

  LoginNotifierData({required this.request, required this.loginState});

  LoginNotifierData copyWith({
    LoginRequestModel? request,
    PageState? loginState,
  }) =>
      LoginNotifierData(
        request: request ?? this.request,
        loginState: loginState ?? this.loginState,
      );
}
