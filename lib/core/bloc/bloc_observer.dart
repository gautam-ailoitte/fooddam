// lib/core/bloc/bloc_observer.dart
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
    
    // Only log if debug level is enabled
    if (_logger.shouldLog(LogLevel.debug)) {
      final blocType = bloc.runtimeType;
      _logger.d('onCreate', tag: 'BLOC:$blocType');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    
    // Only do the work if debug logs are enabled
    if (_logger.shouldLog(LogLevel.debug)) {
      final blocType = bloc.runtimeType;
      
      if (detailedLogs) {
        // For detailed logs, log the bloc type but avoid full state toString()
        _logger.d('onChange', tag: 'BLOC:$blocType');
        
        // Log current and next state types separately
        final currentType = change.currentState?.runtimeType ?? 'null';
        final nextType = change.nextState?.runtimeType ?? 'null';
        _logger.d('Current: $currentType → Next: $nextType', tag: 'BLOC:$blocType');
      } else {
        // For minimal logs, just log the state types
        final currentType = change.currentState?.runtimeType ?? 'null';
        final nextType = change.nextState?.runtimeType?? 'null';
        _logger.d('onChange: $currentType → $nextType', tag: 'BLOC:$blocType');
      }
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    // Errors are important enough to log with full details
    final blocType = bloc.runtimeType;
    _logger.e('onError', tag: 'BLOC:$blocType', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    
    // Only log if debug level is enabled
    if (_logger.shouldLog(LogLevel.debug)) {
      final blocType = bloc.runtimeType;
      _logger.d('onClose', tag: 'BLOC:$blocType');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    
    // Only do the work if debug logs are enabled
    if (_logger.shouldLog(LogLevel.debug)) {
      final blocType = bloc.runtimeType;
      final eventType = event?.runtimeType ?? 'null';
      
      if (detailedLogs) {
        _logger.d('onEvent: $eventType', tag: 'BLOC:$blocType');
      } else {
        _logger.d('onEvent: $eventType', tag: 'BLOC:$blocType');
      }
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    
    // Only do the work if debug logs are enabled
    if (_logger.shouldLog(LogLevel.debug)) {
      final blocType = bloc.runtimeType;
      
      // Get all type names to avoid toString() on full objects
      final eventType = transition.event.runtimeType;
      final currentType = transition.currentState.runtimeType;
      final nextType = transition.nextState.runtimeType;
      
      if (detailedLogs) {
        _logger.d('onTransition Event: $eventType', tag: 'BLOC:$blocType');
        _logger.d('  $currentType → $nextType', tag: 'BLOC:$blocType');
      } else {
        _logger.d('onTransition: $eventType, $currentType → $nextType', tag: 'BLOC:$blocType');
      }
    }
  }
}