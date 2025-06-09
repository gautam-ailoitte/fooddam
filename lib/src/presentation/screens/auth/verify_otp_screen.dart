// lib/src/presentation/screens/auth/verify_otp_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/auth/sms_otp_service.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

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
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final SmsOtpService _smsOtpService = SmsOtpService();

  bool _isResendingOTP = false;
  bool _isVerifyingOTP = false; // ✅ NEW: Track verification state
  bool _hasNavigated = false; // ✅ NEW: Prevent multiple navigation
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  Timer? _verificationDebouncer; // ✅ NEW: Debounce verification

  // Pin themes - initialized in didChangeDependencies
  PinTheme? defaultPinTheme;
  PinTheme? focusedPinTheme;
  PinTheme? submittedPinTheme;
  PinTheme? errorPinTheme;
  bool _themesInitialized = false;

  @override
  void initState() {
    super.initState();
    print('🚀 VerifyOTPScreen initialized for: ${widget.mobileNumber}');
    _startResendTimer();
    _initializeSmsListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize themes here when Theme.of(context) is available
    if (!_themesInitialized) {
      _initializePinThemes();
      _themesInitialized = true;
    }
  }

  @override
  void dispose() {
    print('🧹 Disposing VerifyOTPScreen - cleaning up resources');
    _smsOtpService.stopListening();
    _pinController.dispose();
    _pinFocusNode.dispose();
    _countdownTimer?.cancel();
    _verificationDebouncer?.cancel(); // ✅ NEW: Cancel debouncer
    super.dispose();
  }

  void _initializePinThemes() {
    print('🎨 Initializing pin themes...');

    defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(200, 200, 200, 1),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    focusedPinTheme = defaultPinTheme!.copyDecorationWith(
      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );

    submittedPinTheme = defaultPinTheme!.copyWith(
      decoration: defaultPinTheme!.decoration!.copyWith(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
    );

    errorPinTheme = defaultPinTheme!.copyWith(
      decoration: defaultPinTheme!.decoration!.copyWith(
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    print('✅ Pin themes initialized successfully');
  }

  Future<void> _initializeSmsListening() async {
    if (!mounted) return; // ✅ NEW: Check mounted state

    print('📱 Starting SMS OTP service initialization...');

    try {
      _smsOtpService.onOtpReceived = _handleAutoFilledOtp;
      _smsOtpService.onTimeoutReached = _handleSmsTimeout;

      print('🔄 Starting SMS listener...');
      final started = await _smsOtpService.startListening();

      if (mounted) {
        // ✅ NEW: Check mounted before UI operations
        if (started) {
          print('✅ SMS listener started successfully');
        } else {
          print('❌ SMS listener failed to start');
        }
      }
    } catch (e) {
      print('❌ SMS initialization error: $e');
      if (mounted) {
        // ✅ NEW: Check mounted before UI operations
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS auto-detection unavailable'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleAutoFilledOtp(String otp) {
    print('🎯 AUTO-FILL TRIGGERED: OTP received = $otp');

    if (!mounted) {
      // ✅ NEW: Check mounted state
      print('❌ Widget not mounted, skipping auto-fill');
      return;
    }

    if (_isVerifyingOTP) {
      // ✅ NEW: Prevent if already verifying
      print('❌ Already verifying OTP, skipping auto-fill');
      return;
    }

    print('📝 Setting OTP in controller: $otp');
    _pinController.text = otp;

    // Show success notification with longer duration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OTP auto-detected: $otp'),
                  const Text(
                    'Tap "Verify Now" or wait 3 seconds for auto-verification',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4), // ✅ FIXED: Longer duration
        behavior: SnackBarBehavior.floating, // ✅ NEW: Floating style
        action: SnackBarAction(
          label: 'Verify Now',
          textColor: Colors.white,
          backgroundColor: Colors.green[700],
          onPressed: () {
            if (mounted && !_isVerifyingOTP) {
              // ✅ NEW: Check state
              ScaffoldMessenger.of(
                context,
              ).hideCurrentSnackBar(); // Hide snackbar
              _verifyOTP(otp);
            }
          },
        ),
      ),
    );

    print('⏰ Starting auto-verify timer with longer delay...');
    // ✅ FIXED: Longer delay to give user time to see the notification
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pinController.text == otp && !_isVerifyingOTP) {
        // ✅ NEW: Check verification state
        print('🚀 Auto-verifying OTP after delay: $otp');
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide snackbar before navigation
        _verifyOTP(otp);
      } else {
        print(
          '❌ Auto-verify cancelled - OTP changed, already verifying, or widget unmounted',
        );
      }
    });
  }

  void _handleSmsTimeout() {
    print('⏰ SMS TIMEOUT: Auto-detection timed out');

    if (mounted) {
      // ✅ NEW: Check mounted before UI operations
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Auto-detection timed out. Please enter OTP manually.'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    if (mounted) {
      // ✅ NEW: Check mounted state
      setState(() {
        _resendCountdown = 60;
        _isResendingOTP = false;
      });
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // ✅ NEW: Check mounted for each tick
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendOTP() {
    if (_resendCountdown > 0 || _isResendingOTP || !mounted)
      return; // ✅ NEW: Check mounted

    print('🔄 RESEND OTP: Requesting new OTP...');

    setState(() {
      _isResendingOTP = true;
    });

    context.read<AuthCubit>().resendOTP(
      widget.mobileNumber,
      widget.isRegistration,
    );

    _startResendTimer();

    print('📱 Restarting SMS listener for new OTP...');
    _initializeSmsListening();
  }

  void _verifyOTP(String otp) {
    print('🔐 VERIFY OTP: Attempting to verify OTP = $otp');

    // ✅ NEW: Check if already verifying or navigated
    if (_isVerifyingOTP || _hasNavigated || !mounted) {
      print(
        '❌ VERIFICATION BLOCKED: isVerifying=$_isVerifyingOTP, hasNavigated=$_hasNavigated, mounted=$mounted',
      );
      return;
    }

    if (otp.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      print(
        '❌ INVALID OTP: Length=${otp.length}, Valid digits=${RegExp(r'^[0-9]{6}$').hasMatch(otp)}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid 6-digit OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    print('✅ OTP VALIDATION PASSED: Setting verification state...');

    // ✅ NEW: Set verification state immediately
    setState(() {
      _isVerifyingOTP = true;
    });

    // ✅ NEW: Debounce multiple rapid calls
    _verificationDebouncer?.cancel();
    _verificationDebouncer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || _hasNavigated) return;

      print('📞 Calling auth verification...');

      if (widget.isRegistration) {
        print('📞 Calling verifyMobileOTP for registration');
        context.read<AuthCubit>().verifyMobileOTP(widget.mobileNumber, otp);
      } else {
        print('📞 Calling verifyLoginOTP for login');
        context.read<AuthCubit>().verifyLoginOTP(widget.mobileNumber, otp);
      }
    });
  }

  void _navigateAfterAuth(AuthAuthenticated state) {
    // ✅ NEW: Prevent multiple navigation
    if (_hasNavigated || !mounted) {
      print(
        '❌ Navigation blocked: hasNavigated=$_hasNavigated, mounted=$mounted',
      );
      return;
    }

    print('✅ Authentication successful, navigating...');

    // ✅ NEW: Set navigation flag immediately
    _hasNavigated = true;

    // ✅ FIXED: Hide all snackbars before navigation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    _smsOtpService.stopListening();
    _countdownTimer?.cancel();
    _verificationDebouncer?.cancel();

    // ✅ FIXED: Add small delay to ensure snackbar is hidden
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;

      if (state.needsProfileCompletion) {
        print('👤 Navigating to profile completion');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProfileCompletionScreen(user: state.user),
          ),
        );
      } else {
        print('🏠 Navigating to main screen');
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.mainRoute, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return loading if themes aren't initialized yet
    if (!_themesInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        centerTitle: true,
        elevation: 0,
      ),
      // ✅ FIXED: Make it keyboard-aware and dismissible
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          // ✅ FIXED: Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            print('🔄 Auth state changed: ${state.runtimeType}');

            if (state is AuthAuthenticated) {
              // ✅ FIXED: Hide any snackbars before navigation
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              _navigateAfterAuth(state);
            } else if (state is AuthError) {
              print('❌ Auth error: ${state.message}');

              // ✅ NEW: Reset verification state on error
              if (mounted) {
                setState(() {
                  _isVerifyingOTP = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else if (state is AuthOTPSent) {
              print('✅ OTP sent: ${state.message}');
              if (mounted) {
                setState(() {
                  _isResendingOTP = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else if (state is AuthLoading) {
              // ✅ NEW: Handle loading state properly
              print('⏳ Auth loading state');
            } else {
              // ✅ NEW: Reset verification state for other states
              if (mounted) {
                setState(() {
                  _isVerifyingOTP = false;
                });
              }
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    // ✅ FIXED: Add keyboard padding and proper scrolling behavior
                    padding: EdgeInsets.only(
                      left: AppDimensions.marginLarge,
                      right: AppDimensions.marginLarge,
                      top: AppDimensions.marginLarge,
                      bottom:
                          MediaQuery.of(context).viewInsets.bottom +
                          AppDimensions.marginLarge,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            AppDimensions.marginLarge * 2,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ FIXED: Add flexible space to center content better
                            const Flexible(child: SizedBox(height: 20)),

                            // Lottie Animation
                            Lottie.asset(
                              'assets/lottie/login_bike.json',
                              height: 140,
                            ), // ✅ FIXED: Smaller height
                            const SizedBox(height: AppDimensions.marginMedium),

                            // Title
                            Text(
                              'Verify OTP',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginSmall),

                            // Subtitle
                            Text(
                              'Enter the 6-digit OTP sent to',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.marginSmall),

                            // Mobile Number Display
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.mobileNumber,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginLarge),

                            // PIN Input
                            Pinput(
                              controller: _pinController,
                              focusNode: _pinFocusNode,
                              length: 6,
                              defaultPinTheme: defaultPinTheme!,
                              focusedPinTheme: focusedPinTheme!,
                              submittedPinTheme: submittedPinTheme!,
                              errorPinTheme: errorPinTheme!,
                              showCursor: true,
                              autofocus:
                                  false, // ✅ FIXED: Don't auto-focus to keep keyboard closed
                              keyboardType: TextInputType.number,
                              cursor: Container(
                                width: 2,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              onCompleted: (otp) {
                                print('📝 PINPUT COMPLETED: $otp');
                                if (!_isVerifyingOTP && !_hasNavigated) {
                                  // ✅ NEW: Check state
                                  _verifyOTP(otp);
                                }
                              },
                              onChanged: (value) {
                                print(
                                  '✏️ PINPUT CHANGED: $value (length: ${value.length})',
                                );
                                if (value.isNotEmpty && mounted) {
                                  setState(() {});
                                }
                              },
                              onTap: () {
                                // ✅ NEW: Focus when user taps to open keyboard manually
                                _pinFocusNode.requestFocus();
                              },
                              validator: (pin) {
                                if (pin == null || pin.length != 6) {
                                  return 'Please enter a valid 6-digit OTP';
                                }
                                return null;
                              },
                              pinputAutovalidateMode:
                                  PinputAutovalidateMode.onSubmit,
                              hapticFeedbackType:
                                  HapticFeedbackType.lightImpact,
                              closeKeyboardWhenCompleted:
                                  true, // ✅ FIXED: Close keyboard when complete
                            ),
                            const SizedBox(height: AppDimensions.marginMedium),

                            // ✅ NEW: Tap to focus hint
                            GestureDetector(
                              onTap: () {
                                _pinFocusNode.requestFocus();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.keyboard,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tap here to enter OTP manually',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginMedium),

                            // Resend OTP Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Didn\'t receive OTP?',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed:
                                      _resendCountdown > 0 || _isVerifyingOTP
                                          ? null
                                          : _resendOTP, // ✅ NEW: Disable during verification
                                  child: Text(
                                    _resendCountdown > 0
                                        ? 'Resend in $_resendCountdown s'
                                        : 'Resend OTP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _resendCountdown > 0 ||
                                                  _isVerifyingOTP
                                              ? Colors.grey[400]
                                              : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.marginLarge),

                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                text: 'Verify',
                                onPressed:
                                    _isVerifyingOTP ||
                                            _hasNavigated // ✅ NEW: Disable based on state
                                        ? null
                                        : () => _verifyOTP(_pinController.text),
                                isLoading:
                                    state is AuthLoading ||
                                    _isResendingOTP ||
                                    _isVerifyingOTP, // ✅ NEW: Show loading for verification
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginMedium),

                            // Change Number Button
                            TextButton(
                              onPressed:
                                  state is AuthLoading ||
                                          _isVerifyingOTP // ✅ NEW: Disable during verification
                                      ? null
                                      : () {
                                        if (mounted && !_hasNavigated) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                              child: Text(
                                'Change Number',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.marginMedium),

                            // Auto-detection Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sms_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'OTP will be auto-detected from SMS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ✅ FIXED: Add flexible space at bottom
                            const Flexible(child: SizedBox(height: 20)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
