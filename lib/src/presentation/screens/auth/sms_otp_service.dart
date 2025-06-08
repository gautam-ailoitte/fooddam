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
  static const List<String> skyMarketingSenders = [
    'SKY MARKETING',
    'SKYMARKETING',
    'SKY-MARKETING',
  ];

  bool _isListening = false;
  DateTime? _listeningStartTime;

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

      // Start native SMS listener
      await _methodChannel.invokeMethod('startSmsListener');

      // Listen to SMS events from native side
      _smsSubscription = _eventChannel.receiveBroadcastStream().listen(
        _handleSmsEvent,
        onError: (error) {
          print('❌ SMS event stream error: $error');
          onStatusChanged?.call('SMS detection error');
        },
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
      onStatusChanged?.call('Listening for SMS from Sky Marketing...');

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

      // Check if SMS is from Sky Marketing
      if (_isSkyMarketingSms(sender)) {
        print('✅ SMS from Sky Marketing detected');

        final otp = _extractOtp(body);
        if (otp != null) {
          print('🎯 OTP Extracted: $otp');
          onOtpReceived?.call(otp);
          stopListening();
        } else {
          print('❌ No OTP found in Sky Marketing SMS');
        }
      } else {
        print('❌ SMS not from Sky Marketing, ignoring');
      }
    } catch (e) {
      print('❌ Error handling SMS event: $e');
    }
  }

  /// Check if SMS is from Sky Marketing
  bool _isSkyMarketingSms(String sender) {
    final senderUpper = sender.toUpperCase();
    return skyMarketingSenders.any(
      (skyMarketingSender) => senderUpper.contains(skyMarketingSender),
    );
  }

  /// Extract OTP from SMS body - specific to your format
  String? _extractOtp(String body) {
    // Primary pattern for Sky Marketing: "233809 is your One-Time Password (OTP)"
    final primaryPattern = RegExp(
      r'(\d{6})\s+is\s+your\s+One-Time\s+Password',
      caseSensitive: false,
    );
    final match = primaryPattern.firstMatch(body);

    if (match != null) {
      return match.group(1);
    }

    // Fallback: any 6 digits at start of message
    final fallbackPattern = RegExp(r'^\d{6}');
    final fallbackMatch = fallbackPattern.firstMatch(body);

    return fallbackMatch?.group(0);
  }

  /// Stop listening for SMS
  Future<void> stopListening() async {
    try {
      // Stop native SMS listener
      await _methodChannel.invokeMethod('stopSmsListener');

      await _smsSubscription?.cancel();
      _smsSubscription = null;

      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      _isListening = false;
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

  /// Get listening status text with countdown
  String get statusText {
    if (!_isListening) return 'Auto-detection stopped';

    final remaining = remainingTime;
    if (remaining == null) return 'Listening...';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return 'Listening for Sky Marketing SMS... ${minutes}m ${seconds}s remaining';
    } else {
      return 'Listening for Sky Marketing SMS... ${seconds}s remaining';
    }
  }
}
