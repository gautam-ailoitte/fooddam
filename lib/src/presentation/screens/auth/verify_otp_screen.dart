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
  String? _appSignature;

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
    cancel();
    super.dispose();
  }

  void _listenForCode() async {
    // Get app signature for SMS (Android only)
    _appSignature = await SmsAutoFill().getAppSignature;

    // Listen for SMS code
    SmsAutoFill().listenForCode;
  }

  @override
  void codeUpdated() {
    // Auto-fill received OTP
    if (code != null && code!.length == 6) {
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = code![i];
      }
      // Automatically verify after auto-fill
      _verifyOTP();
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

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    if (widget.isRegistration) {
      context.read<AuthCubit>().verifyMobileOTP(widget.mobileNumber, otp);
    } else {
      context.read<AuthCubit>().verifyLoginOTP(widget.mobileNumber, otp);
    }
  }

  void _handleOtpInput(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
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
                    if (_appSignature != null) ...[
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        'App Signature: $_appSignature',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
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
