import 'package:flutter/material.dart';
import '../utils/navigation_service.dart';

class CustomRouterObserver extends RouteObserver<PageRoute<dynamic>> {
  void _sendScreenView(PageRoute<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      NavigationService.onRouteChanged(routeName);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PageRoute) _sendScreenView(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute is PageRoute) _sendScreenView(newRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute is PageRoute) _sendScreenView(previousRoute);
  }
}