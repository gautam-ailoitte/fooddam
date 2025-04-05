// lib/src/presentation/screens/auth/verify_otp_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';

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

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
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
    super.dispose();
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

    // Call the appropriate API method based on registration or login
    if (widget.isRegistration) {
      context.read<AuthCubit>().registerWithMobile(
        widget.mobileNumber,
        '', // We don't have password here, but the API should handle this case
        true, // Accept terms (should be saved from previous screen)
      );
    } else {
      context.read<AuthCubit>().requestLoginOTP(widget.mobileNumber);
    }

    _startResendTimer();
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOTP() {
    final otp = _getOTP();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    // Verify OTP based on flow type
    if (widget.isRegistration) {
      context.read<AuthCubit>().verifyMobileOTP(widget.mobileNumber, otp);
    } else {
      context.read<AuthCubit>().verifyLoginOTP(widget.mobileNumber, otp);
    }
  }

  // Helper to handle OTP input and focus management
  void _handleOtpInput(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next focus node
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last digit, hide keyboard
        _focusNodes[index].unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP'), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.needsProfileCompletion) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ProfileCompletionScreen(user: state.user),
                ),
              );
            } else {
              // Navigate to main screen
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/main', (route) => false);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthOTPSent) {
            setState(() {
              _isResendingOTP = false;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                    // App logo/animation
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
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 45,
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
                      ),
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

                    // Verify Button
                    PrimaryButton(
                      text: 'Verify',
                      onPressed: _verifyOTP,
                      isLoading: state is AuthLoading || _isResendingOTP,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Back to Login
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
