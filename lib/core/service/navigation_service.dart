// lib/core/service/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  // Global navigation key to be used across the app
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Get the current navigation context
  static BuildContext? get context => navigatorKey.currentContext;

  // Get the current navigation state
  static NavigatorState? get navigator => navigatorKey.currentState;

  // Push a new route
  static Future<T?> push<T>(Widget page) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to push a new page');
      return Future.value(null);
    }
    return nav.push<T>(MaterialPageRoute(builder: (_) => page));
  }

  // Push a named route
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to navigate to $routeName');
      return Future.value(null);
    }
    return nav.pushNamed<T>(routeName, arguments: arguments);
  }

  // Replace the current route with a new one
  static Future<T?> pushReplacement<T, TO>(Widget page) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to push replacement');
      return Future.value(null);
    }
    return nav.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Replace the current named route with a new one
  static Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    Object? arguments,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to navigate to $routeName');
      return Future.value(null);
    }
    return nav.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  // Push a new route and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    Widget page,
    RoutePredicate predicate,
  ) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to push and remove until');
      return Future.value(null);
    }
    return nav.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }

  // Push a new named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to navigate to $routeName');
      return Future.value(null);
    }
    return nav.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  // Pop the current route
  static void pop<T>([T? result]) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to pop');
      return;
    }
    if (nav.canPop()) {
      nav.pop<T>(result);
    }
  }

  // Pop until a specific route
  static void popUntil(RoutePredicate predicate) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to pop until');
      return;
    }
    nav.popUntil(predicate);
  }

  // Navigate to the home page by removing all routes
  static void goToHome() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to go to home');
      return;
    }
    nav.popUntil((route) => route.isFirst);
  }

  // Navigate back to a specific named route
  static void goBackTo(String routeName) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when trying to go back to $routeName');
      return;
    }
    nav.popUntil((route) {
      return route.settings.name == routeName;
    });
  }

  // Check if the route is the first route
  static bool isFirstRoute() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when checking if route is first');
      return true;
    }
    bool isFirst = true;
    nav.popUntil((route) {
      isFirst = route.isFirst;
      return true;
    });
    return isFirst;
  }

  // Get the name of the current route
  static String? getCurrentRouteName() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when getting current route name');
      return null;
    }
    String? currentRouteName;
    nav.popUntil((route) {
      currentRouteName = route.settings.name;
      return true;
    });
    return currentRouteName;
  }

  // Get the arguments of the current route
  static T? getArguments<T>() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when getting arguments');
      return null;
    }
    T? arguments;
    nav.popUntil((route) {
      arguments = route.settings.arguments as T?;
      return true;
    });
    return arguments;
  }

  /// Get current route name
  static String? getCurrentRoute() {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Warning: Navigator is null when getting current route');
      return null;
    }
    String? currentRoute;
    nav.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });
    return currentRoute;
  }
}