// lib/core/bloc/app_bloc_observer.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';

/// Custom BlocObserver for logging and monitoring Bloc events.
class AppBlocObserver extends BlocObserver {
  final LoggerService _logger = LoggerService();
  
  /// Flag to control logging detail level
  /// Set to true for verbose logs with full state data
  /// Set to false for minimal logs with only type information
  static bool detailedLogs = false;
  
  /// Method to toggle between detailed and minimal logs
  static void toggleDetailedLogs(bool detailed) {
    detailedLogs = detailed;
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.d('onCreate -- ', tag: 'BLOC');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    
    if (detailedLogs) {
      // Detailed version - logs full state data
      _logger.d('onChange -- ${bloc.runtimeType}, $change', tag: 'BLOC');
    } else {
      // Minimal version - logs only state types
      final currentType = change.currentState?.runtimeType;
      final nextType = change.nextState?.runtimeType;
      _logger.d('onChange -- , Current: $currentType → Next: $nextType', tag: 'BLOC');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      'onError -- ${bloc.runtimeType}',
      tag: 'BLOC',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.d('onClose -- ${bloc.runtimeType}', tag: 'BLOC');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    
    if (detailedLogs) {
      // Detailed version - logs full event data
      _logger.d('onEvent -- ${bloc.runtimeType}, $event', tag: 'BLOC');
    } else {
      // Minimal version - logs only event type
      _logger.d('onEvent -- , ${event.runtimeType}', tag: 'BLOC');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    
    if (detailedLogs) {
      // Detailed version - logs full transition data
      _logger.d('onTransition -- ${bloc.runtimeType}, $transition', tag: 'BLOC');
    } else {
      // Minimal version - logs only types
      final eventType = transition.event.runtimeType;
      final currentStateType = transition.currentState.runtimeType;
      final nextStateType = transition.nextState.runtimeType;
      _logger.d('onTransition -- , Event: $eventType, $currentStateType → $nextStateType', tag: 'BLOC');
    }
  }
}