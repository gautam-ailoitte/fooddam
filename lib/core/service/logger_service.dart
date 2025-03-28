// lib/core/service/logger_service.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  nothing,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  // Configuration
  bool _enableConsoleLogs = true;
  LogLevel _minimumLogLevel = kDebugMode ? LogLevel.info : LogLevel.error;
  bool _showTime = true;
  bool _showEmoji = true;

  // Set the minimum log level for filtering logs
  void setMinimumLogLevel(LogLevel level) {
    _minimumLogLevel = level;
  }

  // Enable or disable console logs
  void enableConsoleLogs(bool enable) {
    _enableConsoleLogs = enable;
  }

  // Enable or disable timestamp
  void showTime(bool show) {
    _showTime = show;
  }

  // Enable or disable emoji
  void showEmoji(bool show) {
    _showEmoji = show;
  }

  // Log a verbose message (lowest level)
  void v(String message, {String tag = 'VERBOSE', Object? data}) {
    if (shouldLog(LogLevel.verbose)) {
      _log(message, LogLevel.verbose, tag: tag, data: data);
    }
  }

  // Log a debug message
  void d(String message, {String tag = 'DEBUG', Object? data}) {
    if (shouldLog(LogLevel.debug)) {
      _log(message, LogLevel.debug, tag: tag, data: data);
    }
  }

  // Log an info message
  void i(String message, {String tag = 'INFO', Object? data}) {
    if (shouldLog(LogLevel.info)) {
      _log(message, LogLevel.info, tag: tag, data: data);
    }
  }

  // Log a warning message
  void w(String message, {String tag = 'WARNING', Object? data}) {
    if (shouldLog(LogLevel.warning)) {
      _log(message, LogLevel.warning, tag: tag, data: data);
    }
  }

  // Log an error message
  void e(String message, {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    if (shouldLog(LogLevel.error)) {
      _log(message, LogLevel.error, tag: tag, data: error, stackTrace: stackTrace);
    }
  }

  // Check if we should log based on the current log level
  bool shouldLog(LogLevel level) {
    if (!_enableConsoleLogs) return false;
    return level.index >= _minimumLogLevel.index;
  }

  // Get emoji for log level
  String _getEmoji(LogLevel level) {
    if (!_showEmoji) return '';
    
    switch (level) {
      case LogLevel.verbose:
        return '🔍 ';
      case LogLevel.debug:
        return '🐛 ';
      case LogLevel.info:
        return '💡 ';
      case LogLevel.warning:
        return '⚠️ ';
      case LogLevel.error:
        return '❌ ';
      default:
        return '';
    }
  }

  // Get timestamp
  String _getTimestamp() {
    if (!_showTime) return '';
    final now = DateTime.now();
    return '[${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}] ';
  }

  // Internal log method
  void _log(String message, LogLevel level, {
    required String tag,
    Object? data,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;  // Skip logging in release mode
    
    final emoji = _getEmoji(level);
    final timestamp = _getTimestamp();
    final logMessage = '$timestamp$emoji[$tag] ${level.name.toUpperCase()}: $message';
    
    // Format the message with color based on log level
    String coloredMessage;
    switch (level) {
      case LogLevel.verbose:
        coloredMessage = '\x1B[90m$logMessage\x1B[0m'; // Dark gray
        break;
      case LogLevel.debug:
        coloredMessage = '\x1B[37m$logMessage\x1B[0m'; // White
        break;
      case LogLevel.info:
        coloredMessage = '\x1B[36m$logMessage\x1B[0m'; // Cyan
        break;
      case LogLevel.warning:
        coloredMessage = '\x1B[33m$logMessage\x1B[0m'; // Yellow
        break;
      case LogLevel.error:
        coloredMessage = '\x1B[31m$logMessage\x1B[0m'; // Red
        break;
      default:
        coloredMessage = logMessage;
        break;
    }
    
    // Log the message to the console
    developer.log(
      coloredMessage,
      name: 'Foodam',
      time: DateTime.now(),
      error: data,
      stackTrace: stackTrace,
    );
    
    // If there's additional data, print it
    if (data != null && level != LogLevel.error) {
      developer.log('Data: $data', name: 'Foodam');
    }
  }

  // Log method execution time
  void Function() logExecutionTime(String methodName, {String tag = 'PERFORMANCE'}) {
    if (!shouldLog(LogLevel.debug)) return () {};
    
    final startTime = DateTime.now();
    return () {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      d('$methodName executed in ${duration.inMilliseconds}ms', tag: tag);
    };
  }

  // Group logs
  void group(String groupName, void Function() logFunction) {
    if (!kDebugMode) {
      logFunction();
      return;
    }
    
    developer.log('┌── BEGIN: $groupName ──', name: 'Foodam');
    logFunction();
    developer.log('└── END: $groupName ──', name: 'Foodam');
  }
  
  // // Log HTTP request
  // void logHttpRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
  //   if (!shouldLog(LogLevel.debug)) return;
    
  //   group('HTTP REQUEST', () {
  //     d('$method $url', tag: 'HTTP');
  //     if (headers != null && headers.isNotEmpty) {
  //       d('Headers: $headers', tag: 'HTTP');
  //     }
  //     if (body != null) {
  //       d('Body: $body', tag: 'HTTP');
  //     }
  //   });
  // }
  
  // // Log HTTP response
  // void logHttpResponse(String url, int statusCode, dynamic body, {int elapsedMs = 0}) {
  //   if (!shouldLog(LogLevel.debug)) return;
    
  //   final isSuccess = statusCode >= 200 && statusCode < 300;
  //   final logMethod = isSuccess ? d : w;
    
  //   group('HTTP RESPONSE (${elapsedMs}ms)', () {
  //     logMethod('$statusCode $url', tag: 'HTTP');
  //     if (body != null) {
  //       logMethod('Body: $body', tag: 'HTTP');
  //     }
  //   });
  // }
  
  // // Log bloc event for debugging with optimizations
  // void logBlocEvent(String blocName, dynamic event) {
  //   if (!shouldLog(LogLevel.debug)) return;
    
  //   // Only get the type name when we know logging will happen
  //   final eventType = event.runtimeType;
  //   d('Event: $eventType', tag: 'BLOC:$blocName');
  // }
  
  // // Log bloc state change for debugging
  // void logBlocState(String blocName, dynamic prevState, dynamic newState) {
  //   // Check if we should log BEFORE any string creation or toString() calls
  //   if (!shouldLog(LogLevel.debug)) return;
    
  //   // Only get the type names when we know logging will happen
  //   final prevType = prevState.runtimeType;
  //   final nextType = newState.runtimeType;
  //   d('State: $prevType → $nextType', tag: 'BLOC:$blocName');
  // }
  
  // // Log bloc error for debugging
  // void logBlocError(String blocName, Object error, StackTrace stackTrace) {
  //   if (!shouldLog(LogLevel.error)) return;
    
  //   // For errors, we'll keep the full error object since it's critical information
  //   e('Error in $blocName', tag: 'BLOC', error: error, stackTrace: stackTrace);
  // }
}