import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Classed used for navigation in the app
extension AiloitteNavigation on BuildContext {
  /// Function to go to previous screen
  static back(
    BuildContext context,
  ) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  /// Function to go to previous screen
  static backWithData<T extends Object?>(
      BuildContext context, Object? argumentClass) {
    log("pop ${argumentClass.toString()}", name: "navigation");

    return Navigator.pop(context, argumentClass);
  }

  /// Function to navigate to new screen without data passing
  static Future<T?> intent<T>(BuildContext context, String nameRouted) {
    log(nameRouted, name: "navigation");

    return Navigator.pushNamed(context, nameRouted);
  }

  /// Function to navigate to new screen by replacing it with new screen
  static Future<T?> intentWithoutBack<T>(
    BuildContext context,
    String nameRouted,
    Object? argumentClass,
  ) {
    return Navigator.pushReplacementNamed(
      context,
      nameRouted,
      arguments: argumentClass,
    );
  }

  /// Function to navigate to new screen by replacing it with new screen
  static Future<dynamic> intentWithoutBackWithData(
    BuildContext context,
    String nameRouted,
    Object? argumentClass,
  ) {
    return Navigator.pushReplacementNamed(
      context,
      nameRouted,
      arguments: argumentClass,
    );
  }

  /// Function to navigation to new screen and remove all other screens in backstack
  static intentWithClearAllRoutes(BuildContext context, String nameRouted) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(nameRouted, (Route<dynamic> route) => false);
  }

  /// Function to navigate to new screen and passing some data
  static Future<T?> intentWithData<T extends Object?>(
    BuildContext context,
    String nameRouted,
    Object? argumentClass,
  ) {
    log(nameRouted, name: "navigation");

    return Navigator.pushNamed(
      context,
      nameRouted,
      arguments: argumentClass,
    );
  }

  /// Function to navigate to new screen and wait for result
  static Future<dynamic> intentWithResult(
    BuildContext context,
    String nameRouted,
  ) {
    log(nameRouted, name: "navigation");

    return Navigator.pushNamed(context, nameRouted);
  }

  /// Function to navigate to new screen and passing some data
  static Future<dynamic> intentWithDataAndResult(
    BuildContext context,
    String nameRouted,
    Object? argumentClass,
  ) {
    return Navigator.pushNamed(context, nameRouted, arguments: argumentClass);
  }

  /// Function to navigation to new screen and remove all other screens in backstack
  static intentWithClearAllRoutesWithData(
    BuildContext context,
    String nameRouted, {
    Object? argumentClass,
  }) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      nameRouted,
      (Route<dynamic> route) => false,
      arguments: argumentClass,
    );
  }

  /// Function to pop until the nameRouted
  static backUntil(BuildContext context, String nameRouted) {
    Navigator.popUntil(
      context,
      ModalRoute.withName(nameRouted),
    );
  }

  /// Navigation while removing current screen from stack, using unitl
}
