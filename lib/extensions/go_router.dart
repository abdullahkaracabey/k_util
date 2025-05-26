import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  String get currentRoute {
    if (routerDelegate.currentConfiguration.isNotEmpty &&
        routerDelegate.currentConfiguration.matches.last
            is ImperativeRouteMatch) {
      return (routerDelegate.currentConfiguration.matches.last
              as ImperativeRouteMatch)
          .matches
          .uri
          .toString();
    } else {
      return routerDelegate.currentConfiguration.uri.toString();
    }
  }

  void popUntil(String path) {
    while (currentRoute != path && canPop()) {
      pop();
    }
  }
}
