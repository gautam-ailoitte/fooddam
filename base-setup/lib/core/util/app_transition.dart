import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppTransition {
  static CustomTransitionPage<T> buildSlideTransition<T>({
    required Widget child,
    Curve curve = Curves.easeInOut,
    Offset beginOffset = const Offset(1.0, 0.0),
    Offset endOffset = Offset.zero,
  }) {
    return CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(begin: beginOffset, end: endOffset).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
