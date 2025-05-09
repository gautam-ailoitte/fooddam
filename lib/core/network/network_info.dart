import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../service/logger_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  final LoggerService _logger = LoggerService();

  // Add caching to avoid repeated expensive checks
  bool? _lastConnectionStatus;
  DateTime? _lastCheckTime;
  static const Duration _cacheDuration = Duration(seconds: 3);

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    final stopwatch = Stopwatch()..start();
    _logger.d('🌐 Starting network connectivity check');

    // Use cached result if available and recent
    final now = DateTime.now();
    if (_lastConnectionStatus != null && _lastCheckTime != null) {
      final timeSinceLastCheck = now.difference(_lastCheckTime!);
      if (timeSinceLastCheck < _cacheDuration) {
        _logger.d(
          '🌐 Using cached connectivity result: $_lastConnectionStatus (${timeSinceLastCheck.inMilliseconds}ms old)',
        );
        return _lastConnectionStatus!;
      }
    }

    // If no recent cache, perform the check with timeout
    try {
      final result = await connectionChecker.hasConnection.timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          _logger.w('🌐 Network check timed out after 1s, assuming connected');
          return true; // Assume connected on timeout
        },
      );

      // Update cache
      _lastConnectionStatus = result;
      _lastCheckTime = now;

      stopwatch.stop();
      _logger.d(
        '🌐 Network connectivity check completed in ${stopwatch.elapsedMilliseconds}ms: $result',
      );

      return result;
    } catch (e) {
      _logger.e('🌐 Network check error', error: e);
      // Assume connected on error rather than blocking the app
      return true;
    }
  }
}
