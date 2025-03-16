// lib/core/services/navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  // Global navigation key to be used across the app
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  // Get the current navigation context
  static BuildContext? get context => navigatorKey.currentContext;
  
  // Get the current navigation state
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  // Push a new route
  static Future<T?> push<T>(Widget page) {
    return navigator!.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  // Push a named route
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }
  
  // Replace the current route with a new one
  static Future<T?> pushReplacement<T, TO>(Widget page) {
    return navigator!.pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  // Replace the current named route with a new one
  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigator!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }
  
  // Push a new route and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(Widget page, RoutePredicate predicate) {
    return navigator!.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate,
    );
  }
  
  // Push a new named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T>(String routeName, RoutePredicate predicate, {Object? arguments}) {
    return navigator!.pushNamedAndRemoveUntil<T>(routeName, predicate, arguments: arguments);
  }
  
  // Pop the current route
  static void pop<T>([T? result]) {
    if (navigator!.canPop()) {
      navigator!.pop<T>(result);
    }
  }
  
  // Pop until a specific route
  static void popUntil(RoutePredicate predicate) {
    navigator!.popUntil(predicate);
  }
  
  // Navigate to the home page by removing all routes
  static void goToHome() {
    navigator!.popUntil((route) => route.isFirst);
  }
  
  // Navigate back to a specific named route
  static void goBackTo(String routeName) {
    navigator!.popUntil((route) {
      return route.settings.name == routeName;
    });
  }
  
  // Check if the route is the first route
  static bool isFirstRoute() {
    bool isFirst = true;
    navigator!.popUntil((route) {
      isFirst = route.isFirst;
      return true;
    });
    return isFirst;
  }
  
  // Get the name of the current route
  static String? getCurrentRouteName() {
    String? currentRouteName;
    navigator!.popUntil((route) {
      currentRouteName = route.settings.name;
      return true;
    });
    return currentRouteName;
  }
  
  // Get the arguments of the current route
  static T? getArguments<T>() {
    T? arguments;
    navigator!.popUntil((route) {
      arguments = route.settings.arguments as T?;
      return true;
    });
    return arguments;
  }
}