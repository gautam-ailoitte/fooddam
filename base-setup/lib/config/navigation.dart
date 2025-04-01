import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Classed used for navigation in the app
@Deprecated("Use AiloitteNavigation")
class  Navigation {
  /// Function to go to previous screen
  static back(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  /// Function to go to previous screen
  static backWithData(BuildContext context, Object? argumentClass) {
    Navigator.pop(context, argumentClass);
  }

  /// Function to navigate to new screen without data passing
  static intent(BuildContext context, String nameRouted) {
    Navigator.pushNamed(context, nameRouted);
  }

  /// Function to navigate to new screen by replacing it with new screen
  static intentWithoutBack(
      BuildContext context, String nameRouted, Object? argumentClass,) {
    Navigator.pushReplacementNamed(context, nameRouted,
        arguments: argumentClass,);
  }

  /// Function to navigate to new screen by replacing it with new screen
  static intentWithoutBackLr(
      BuildContext context, String nameRouted, String lastRoute,  Object? argumentClass,) {
    Navigator.pushReplacementNamed(context, nameRouted,
        arguments: argumentClass,);
  }

  /// Function to navigation to new screen and remove all other screens in backstack
  static intentWithClearAllRoutes(BuildContext context, String nameRouted) {
    Navigator.of(context).pushNamedAndRemoveUntil(nameRouted,(Route<dynamic> route) {
      return false;
    });
  }
  /// Function to navigation to new screen and remove all other screens in backstack
  static intentWithClearAllRoutesPred(BuildContext context, String nameRouted, String previousRoute) {
    Navigator.of(context).pushNamedAndRemoveUntil(nameRouted,(Route<dynamic> route) {
      // ignore: unrelated_type_equality_checks
      route == previousRoute;
      return false ;
    });
  }

  /// Function to navigate to new screen and passing some data
  static intentWithData(
      BuildContext context, String nameRouted, Object? argumentClass,) {
    Navigator.pushNamed(context, nameRouted, arguments: argumentClass);
  }

  /// Function to navigate to new screen and passing some data
  static Future<dynamic> intentWithDataAndResult(
      BuildContext context, String nameRouted, Object? argumentClass,) {
    return Navigator.pushNamed(context, nameRouted, arguments: argumentClass);
  }

  /// Function to navigation to new screen and remove all other screens in backstack
  static intentWithClearAllRoutesWithData(
      BuildContext context, String nameRouted, Object? argumentClass,) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        nameRouted, (Route<dynamic> route) => false,
        arguments: argumentClass,);
  }
}
