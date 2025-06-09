// lib/core/services/sms_otp_service.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsOtpService {
  static final SmsOtpService _instance = SmsOtpService._internal();
  factory SmsOtpService() => _instance;
  SmsOtpService._internal();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.foodam.sms/method',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.foodam.sms/events',
  );

  StreamSubscription<dynamic>? _smsSubscription;
  Timer? _timeoutTimer;

  // Callbacks
  Function(String otp)? onOtpReceived;
  Function()? onTimeoutReached;
  Function(String status)? onStatusChanged;

  // Configuration
  static const int timeoutMinutes = 2;

  // Check both sender patterns and content patterns
  static const List<String> skyMarketingSenders = [
    'SKY MARKETING',
    'SKYMARKETING',
    'SKY-MARKETING',
    'JD-MARSKY-S', // Add the actual sender ID we're seeing
    'MARSKY',
    'SKY',
  ];

  // Content patterns that indicate Sky Marketing SMS
  static const List<String> skyMarketingContentPatterns = [
    '-Sky Marketing',
    '- Sky Marketing',
    'Sky Marketing',
    'is your One-Time Password (OTP)',
    'is your OTP',
  ];

  bool _isListening = false;
  DateTime? _listeningStartTime;
  String?
  _lastProcessedOtp; // ✅ NEW: Track last processed OTP to prevent duplicates
  DateTime? _lastOtpTime; // ✅ NEW: Track when last OTP was processed

  /// Request SMS permissions
  Future<bool> requestSmsPermissions() async {
    try {
      var status = await Permission.sms.status;

      if (status.isGranted) {
        return true;
      }

      status = await Permission.sms.request();
      return status.isGranted;
    } catch (e) {
      print('❌ Error requesting SMS permission: $e');
      return false;
    }
  }

  /// Start listening for SMS with 2-minute timeout
  Future<bool> startListening() async {
    try {
      if (!await requestSmsPermissions()) {
        print('❌ SMS permission not granted');
        onStatusChanged?.call('SMS permission required');
        return false;
      }

      await stopListening();

      // ✅ NEW: Reset tracking variables
      _lastProcessedOtp = null;
      _lastOtpTime = null;

      // Start native SMS listener
      await _methodChannel.invokeMethod('startSmsListener');

      // Listen to SMS events from native side
      _smsSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleSmsEvent,
        onError: (error) {
          print('❌ SMS event stream error: $error');
          onStatusChanged?.call('SMS detection error');
        },
        cancelOnError: false, // ✅ NEW: Don't cancel on errors
      );

      _isListening = true;
      _listeningStartTime = DateTime.now();

      // Start 2-minute timeout timer
      _timeoutTimer = Timer(const Duration(minutes: timeoutMinutes), () {
        print('⏰ SMS listening timeout reached after $timeoutMinutes minutes');
        onStatusChanged?.call('Auto-detection timed out');
        onTimeoutReached?.call();
        stopListening();
      });

      print('✅ SMS OTP listener started for $timeoutMinutes minutes');
      onStatusChanged?.call('Listening for OTP from Sky Marketing...');

      return true;
    } catch (e) {
      print('❌ Error starting SMS listener: $e');
      onStatusChanged?.call('Failed to start auto-detection');
      return false;
    }
  }

  /// Handle SMS event from native side
  void _handleSmsEvent(dynamic event) {
    if (!_isListening) return;

    try {
      final Map<String, dynamic> smsData = Map<String, dynamic>.from(event);
      final String body = smsData['body'] ?? '';
      final String sender = smsData['sender'] ?? '';

      print('📨 New SMS from: $sender');
      print('📝 SMS Body: $body');

      // Check if SMS is from Sky Marketing (either by sender OR content)
      if (_isSkyMarketingSms(sender, body)) {
        print('✅ Sky Marketing SMS detected');

        final otp = _extractOtp(body);
        if (otp != null) {
          // ✅ NEW: Check for duplicate OTP processing
          if (_isDuplicateOtp(otp)) {
            print('⚠️ Duplicate OTP detected, ignoring: $otp');
            return;
          }

          print('🎯 OTP Extracted: $otp');

          // ✅ NEW: Update tracking variables
          _lastProcessedOtp = otp;
          _lastOtpTime = DateTime.now();

          onOtpReceived?.call(otp);
          stopListening();
        } else {
          print('❌ No OTP found in Sky Marketing SMS');
        }
      } else {
        print('❌ SMS not from Sky Marketing, ignoring');
        print('🔍 Sender: $sender');
        print(
          '🔍 Body contains Sky Marketing patterns: ${_containsSkyMarketingContent(body)}',
        );
      }
    } catch (e) {
      print('❌ Error handling SMS event: $e');
      // ✅ NEW: Don't stop listening on single SMS processing errors
    }
  }

  /// ✅ NEW: Check if this OTP was recently processed to prevent duplicates
  bool _isDuplicateOtp(String otp) {
    if (_lastProcessedOtp == null || _lastOtpTime == null) {
      return false;
    }

    // Same OTP within last 30 seconds is considered duplicate
    final timeDiff = DateTime.now().difference(_lastOtpTime!);
    return _lastProcessedOtp == otp && timeDiff.inSeconds < 30;
  }

  /// Check if SMS is from Sky Marketing - Enhanced to check both sender AND content
  bool _isSkyMarketingSms(String sender, String body) {
    try {
      // Check sender patterns
      final senderMatch = _containsSkyMarketingSender(sender);

      // Check content patterns
      final contentMatch = _containsSkyMarketingContent(body);

      // Accept if either sender OR content indicates Sky Marketing
      final isMatch = senderMatch || contentMatch;

      print('🔍 SMS Analysis:');
      print('   Sender Match: $senderMatch (sender: $sender)');
      print('   Content Match: $contentMatch');
      print('   Overall Match: $isMatch');

      return isMatch;
    } catch (e) {
      print('❌ Error analyzing SMS: $e');
      return false;
    }
  }

  /// Check if sender matches Sky Marketing patterns
  bool _containsSkyMarketingSender(String sender) {
    try {
      final senderUpper = sender.toUpperCase();
      return skyMarketingSenders.any(
        (skyMarketingSender) =>
            senderUpper.contains(skyMarketingSender.toUpperCase()),
      );
    } catch (e) {
      print('❌ Error checking sender patterns: $e');
      return false;
    }
  }

  /// Check if content contains Sky Marketing patterns
  bool _containsSkyMarketingContent(String body) {
    try {
      return skyMarketingContentPatterns.any(
        (pattern) => body.contains(pattern),
      );
    } catch (e) {
      print('❌ Error checking content patterns: $e');
      return false;
    }
  }

  /// Extract OTP from SMS body - Enhanced patterns
  String? _extractOtp(String body) {
    try {
      // Primary pattern for Sky Marketing: "233809 is your One-Time Password (OTP)"
      final primaryPattern = RegExp(
        r'(\d{6})\s+is\s+your\s+One-Time\s+Password',
        caseSensitive: false,
      );
      final match = primaryPattern.firstMatch(body);

      if (match != null) {
        return match.group(1);
      }

      // Secondary pattern: "123456 is your OTP"
      final secondaryPattern = RegExp(
        r'(\d{6})\s+is\s+your\s+OTP',
        caseSensitive: false,
      );
      final secondaryMatch = secondaryPattern.firstMatch(body);

      if (secondaryMatch != null) {
        return secondaryMatch.group(1);
      }

      // Fallback: any 6 digits at start of message (for your specific format)
      final fallbackPattern = RegExp(r'^\d{6}');
      final fallbackMatch = fallbackPattern.firstMatch(body);

      return fallbackMatch?.group(0);
    } catch (e) {
      print('❌ Error extracting OTP: $e');
      return null;
    }
  }

  /// Stop listening for SMS
  Future<void> stopListening() async {
    try {
      _isListening = false;

      // Stop native SMS listener
      try {
        await _methodChannel.invokeMethod('stopSmsListener');
      } catch (e) {
        print('⚠️ Error stopping native SMS listener: $e');
      }

      // Cancel subscription
      await _smsSubscription?.cancel();
      _smsSubscription = null;

      // Cancel timeout timer
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      // Reset state
      _listeningStartTime = null;

      print('🛑 SMS OTP listener stopped');
      onStatusChanged?.call('Auto-detection stopped');
    } catch (e) {
      print('❌ Error stopping SMS listener: $e');
    }
  }

  /// Get remaining listening time
  Duration? get remainingTime {
    if (!_isListening || _listeningStartTime == null) return null;

    final elapsed = DateTime.now().difference(_listeningStartTime!);
    final total = const Duration(minutes: timeoutMinutes);
    final remaining = total - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// ✅ NEW: Get detailed status information
  Map<String, dynamic> get statusInfo => {
    'isListening': _isListening,
    'remainingTime': remainingTime?.inSeconds,
    'lastOtpTime': _lastOtpTime?.toIso8601String(),
    'hasPermission': Permission.sms.isGranted,
  };

  /// Get listening status text with countdown
  String get statusText {
    if (!_isListening) return 'Auto-detection stopped';

    final remaining = remainingTime;
    if (remaining == null) return 'Listening...';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return 'Listening for OTP SMS... ${minutes}m ${seconds}s remaining';
    } else {
      return 'Listening for OTP SMS... ${seconds}s remaining';
    }
  }

  /// ✅ NEW: Force cleanup method
  Future<void> forceCleanup() async {
    print('🧹 Force cleanup SMS OTP service');

    _isListening = false;
    _lastProcessedOtp = null;
    _lastOtpTime = null;

    await _smsSubscription?.cancel();
    _smsSubscription = null;

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    _listeningStartTime = null;

    try {
      await _methodChannel.invokeMethod('stopSmsListener');
    } catch (e) {
      print('⚠️ Error in force cleanup: $e');
    }
  }
}
