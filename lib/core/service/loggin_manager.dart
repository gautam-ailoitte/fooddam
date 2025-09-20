// lib/core/service/logging_manager.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/service/logger_service.dart';

/// LogLevel to determine the amount of logging
enum AppLogLevel {
  /// No logs at all
  none,
  
  /// Only critical errors
  critical,
  
  /// Errors and warnings only
  error,
  
  /// General app flow (navigation, key events)
  info,
  
  /// Detailed logs for debugging (API requests, state changes)
  debug,
  
  /// All possible logs (verbose data dumps, detailed state)
  verbose
}

/// Central logging manager for the entire application
/// 
/// This class controls all logging throughout the app, including:
/// - LoggerService logs
/// - BLoC observer logs
/// - API client logs
/// - Any other logging sources
class LoggingManager {
  static final LoggingManager _instance = LoggingManager._internal();
  factory LoggingManager() => _instance;
  
  LoggingManager._internal();
  
  final LoggerService _logger = LoggerService();
  
  /// Current application log level
  AppLogLevel _currentLogLevel = kDebugMode ? AppLogLevel.info : AppLogLevel.none;
  
  /// Initialize logging with the specified level
  void initialize({AppLogLevel? logLevel}) {
    // Set log level if provided, otherwise use default
    _currentLogLevel = logLevel ?? _currentLogLevel;
    
    // Configure logger service based on log level
    _configureLoggerService();
    
    // Configure BLoC observer based on log level
    _configureBlocObserver();
    
    // Log the initialization
    _logger.i('LoggingManager initialized with level: $_currentLogLevel');
  }
  
  /// Get the logger service instance
  LoggerService get logger => _logger;
  
  /// Get the current log level
  AppLogLevel get currentLogLevel => _currentLogLevel;
  
  /// Set a new log level
  void setLogLevel(AppLogLevel level) {
    _currentLogLevel = level;
    _configureLoggerService();
    _configureBlocObserver();
    _logger.i('Log level changed to: $level');
  }
  
  /// Configure LoggerService based on current log level
  void _configureLoggerService() {
    // Enable or disable console logs
    _logger.enableConsoleLogs(_currentLogLevel != AppLogLevel.none);
    
    // Set minimum log level
    switch (_currentLogLevel) {
      case AppLogLevel.none:
        _logger.setMinimumLogLevel(LogLevel.nothing);
        break;
      case AppLogLevel.critical:
        _logger.setMinimumLogLevel(LogLevel.error);
        break;
      case AppLogLevel.error:
        _logger.setMinimumLogLevel(LogLevel.warning);
        break;
      case AppLogLevel.info:
        _logger.setMinimumLogLevel(LogLevel.info);
        break;
      case AppLogLevel.debug:
        _logger.setMinimumLogLevel(LogLevel.debug);
        break;
      case AppLogLevel.verbose:
        _logger.setMinimumLogLevel(LogLevel.verbose);
        break;
    }
  }
  
  /// Configure BLoC observer based on current log level
  void _configureBlocObserver() {
    // Only set observer in debug mode
    if (!kDebugMode) return;
    
    // Setup a dummy observer that does nothing when logging is disabled

    // Configure AppBlocObserver
    switch (_currentLogLevel) {
      case AppLogLevel.none:
      case AppLogLevel.critical:
      case AppLogLevel.error:
        // Use a no-op observer for these levels to avoid null assignment
        Bloc.observer = NoOpBlocObserver();
        break;
      case AppLogLevel.info:
        // Enable BLoC observer with minimal logs (no detailed data)
        AppBlocObserver.toggleDetailedLogs(false);
        Bloc.observer = AppBlocObserver();
        break;
      case AppLogLevel.debug:
      case AppLogLevel.verbose:
        // Enable BLoC observer with detailed logs
        AppBlocObserver.toggleDetailedLogs(_currentLogLevel == AppLogLevel.verbose);
        Bloc.observer = AppBlocObserver();
        break;
    }
  }
  
  /// Configure API logging for Dio based on current log level
  bool shouldLogApi() {
    return _currentLogLevel.index >= AppLogLevel.debug.index;
  }
  
  /// Configure API logging for detailed request/response based on current log level
  bool shouldLogDetailedApi() {
    return _currentLogLevel.index >= AppLogLevel.verbose.index;
  }
}
 class NoOpBlocObserver extends BlocObserver {}