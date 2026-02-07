import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  static String? _currentRouteNamee;

  static String? get currentRouteName => _currentRouteNamee;

  static void onRouteChanged(String? routeName) {
    _currentRouteNamee = routeName;
    // debugPrint('📍 Current route updated: $_currentRouteNamee');
  }

  static Future<T?> push<T extends Object?>(
    Route<T> route, {
    Object? args,
  }) async =>
      navigationKey.currentState?.push(route);

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? args,
  }) async =>
      navigationKey.currentState?.pushNamed<T>(
        routeName,
        arguments: args,
      );

  static Future<T?> pushReplaceNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? args,
    TO? result,
  }) async =>
      navigationKey.currentState
          ?.pushReplacementNamed(routeName, arguments: args, result: result);

  static Future<T?> pushNamedAndRemoveAll<T extends Object?>(
    String routeName, {
    Object? args,
  }) async =>
      navigationKey.currentState?.pushNamedAndRemoveUntil(
        routeName,
        arguments: args,
        (route) => false,
      );

  static Future<void> pop({Object? callback}) async =>
      navigationKey.currentState?.pop(callback);

  static Future<void> popUntilNamed(String routeName) async =>
      navigationKey.currentState
          ?.popUntil((route) => route.settings.name == routeName);

  static Future<Future<bool>?> maybePop({Object? callback}) async =>
      navigationKey.currentState?.maybePop(callback);

  static BuildContext get globalContext => navigationKey.currentContext!;
}
