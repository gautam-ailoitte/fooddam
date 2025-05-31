// lib/src/presentation/screens/auth/verify_otp_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String mobileNumber;
  final bool isRegistration;

  const VerifyOTPScreen({
    super.key,
    required this.mobileNumber,
    this.isRegistration = true,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> with CodeAutoFill {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isResendingOTP = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _listenForCode();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    cancel(); // SMS auto-fill cleanup
    super.dispose();
  }

  void _listenForCode() async {
    // Listen for SMS code
    SmsAutoFill().listenForCode;
  }

  @override
  void codeUpdated() {
    // Auto-fill received OTP without auto-verification
    if (code != null && code!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = code![i];
      }

      // Show confirmation instead of auto-verifying
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('OTP auto-filled. Tap verify to continue.'),
          action: SnackBarAction(
            label: 'Verify',
            onPressed: _verifyOTP,
          ),
        ),
      );
    }
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
      _isResendingOTP = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _countdownTimer?.cancel();
        }
      });
    });
  }

  void _resendOTP() {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResendingOTP = true;
    });

    context.read<AuthCubit>().resendOTP(
      widget.mobileNumber,
      widget.isRegistration,
    );

    _startResendTimer();
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() {
    final otp = _getOTP();

    // Simple OTP validation
    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Proceed with verification
    if (widget.isRegistration) {
      context.read<AuthCubit>().verifyMobileOTP(widget.mobileNumber, otp);
    } else {
      context.read<AuthCubit>().verifyLoginOTP(widget.mobileNumber, otp);
    }
  }

  void _handleOtpInput(String value, int index) {
    debugPrint('🔤 OTP Input - Index: $index, Value: "$value", Previous: "${_otpControllers[index].text}"');

    // Handle input (when character is added)
    if (value.isNotEmpty) {
      debugPrint('➡️ Character added at index $index: "$value"');

      // If user typed more than one character (paste), handle it
      if (value.length > 1) {
        debugPrint('📋 Paste detected: "$value"');
        _handlePastedOTP(value, index);
        return;
      }

      // Move to next field for single character input
      if (index < 5) {
        debugPrint('⏭️ Moving to next field: ${index + 1}');
        _focusNodes[index + 1].requestFocus();
      } else {
        debugPrint('🏁 Last field reached, removing focus');
        _focusNodes[index].unfocus();

        // Auto-verify when last digit is entered and OTP is complete
        final completeOtp = _getOTP();
        debugPrint('🔍 Complete OTP: "$completeOtp" (length: ${completeOtp.length})');
        if (completeOtp.length == 6) {
          debugPrint('✅ Auto-verifying complete OTP');
          _verifyOTP();
        }
      }
    }
    // Handle deletion is managed by KeyboardListener, not here
    // This prevents interference between the two mechanisms
  }

  void _handlePastedOTP(String pastedText, int startIndex) {
    debugPrint('📋 Handling pasted text: "$pastedText" starting at index $startIndex');
    final digits = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('🔢 Extracted digits: "$digits"');

    for (int i = 0; i < digits.length && (startIndex + i) < 6; i++) {
      _otpControllers[startIndex + i].text = digits[i];
      debugPrint('📝 Set field ${startIndex + i} to "${digits[i]}"');
    }

    // Focus on next empty field or verify if complete
    final nextEmptyIndex = _otpControllers.indexWhere((c) => c.text.isEmpty);
    if (nextEmptyIndex != -1) {
      debugPrint('🎯 Focusing on next empty field: $nextEmptyIndex');
      _focusNodes[nextEmptyIndex].requestFocus();
    } else {
      final completeOtp = _getOTP();
      debugPrint('🔍 Complete OTP after paste: "$completeOtp"');
      if (completeOtp.length == 6) {
        debugPrint('✅ Auto-verifying pasted OTP');
        _verifyOTP();
      }
    }
  }

  void _navigateAfterAuth(AuthAuthenticated state) {
    if (state.needsProfileCompletion) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileCompletionScreen(user: state.user),
        ),
      );
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.mainRoute,
            (route) => false,
      );
    }
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          debugPrint('⌨️ KeyEvent at index $index: ${event.runtimeType}, Key: ${event.logicalKey}');

          // Handle backspace key specifically for better UX
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {

            final currentText = _otpControllers[index].text;
            debugPrint('⬅️ Backspace detected - Current text: "$currentText", Index: $index');

            // If current field is empty and we're not at the first field
            if (currentText.isEmpty && index > 0) {
              debugPrint('🔙 Moving to previous field: ${index - 1}');
              _focusNodes[index - 1].requestFocus();
              // Also clear the previous field for better UX
              _otpControllers[index - 1].text = '';
            }
            // If current field has content, let the TextFormField handle it naturally
            else if (currentText.isNotEmpty) {
              debugPrint('🧹 Current field has content, will be cleared by TextFormField');
            }
          }
        },
        child: TextFormField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: '',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _handleOtpInput(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP'), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          debugPrint('🎯 OTPScreen BlocListener - State: ${state.runtimeType}');

          if (state is AuthAuthenticated) {
            debugPrint('✅ OTP Verification successful - navigating after auth');
            _navigateAfterAuth(state);
          } else if (state is AuthError) {
            debugPrint('❌ OTP Error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthOTPSent) {
            debugPrint('📨 OTP Resent successfully');
            setState(() {
              _isResendingOTP = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthLoading) {
            debugPrint('⏳ OTP Screen - Auth Loading');
          } else {
            debugPrint('🔄 OTP Screen - Other state: ${state.runtimeType}');
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.marginLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/login_bike.json', height: 160),
                    const SizedBox(height: AppDimensions.marginLarge),
                    Text(
                      'Verify OTP',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      'Enter the 6-digit OTP sent to',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      widget.mobileNumber,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.marginExtraLarge),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) => _buildOtpField(index)),
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    // Resend OTP Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive OTP?',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _resendCountdown > 0 ? null : _resendOTP,
                          child: Text(
                            _resendCountdown > 0
                                ? 'Resend in $_resendCountdown s'
                                : 'Resend OTP',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    PrimaryButton(
                      text: 'Verify',
                      onPressed: _verifyOTP,
                      isLoading: state is AuthLoading || _isResendingOTP,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    TextButton(
                      onPressed:
                      state is AuthLoading
                          ? null
                          : () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Change Number'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}