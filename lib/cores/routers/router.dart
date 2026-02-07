import 'package:flutter/material.dart';
import '../../features/login/views/login_view.dart';
import '../../features/splash/views/splash_view.dart';
import 'router_constant.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // final args = settings.arguments;
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginView(),
        );
      case Routes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SplashView(),
        );
      // case Routes.profileNakes:
      //   final data = args as ProfileNakesArgsModel;

      //   return MaterialPageRoute(
      //     settings: settings,
      //     builder: (_) => ProfileNakesView(args: data),
      //   );
      default:
        return _notFoundPage();
    }
  }

  static Route<dynamic> _notFoundPage() => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Error!')),
          body:
              const Center(child: Text('Page not found!, add your page here')),
        ),
      );
}
