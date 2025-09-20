// lib/src/presentation/screens/auth/login_screen.dart
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
import 'package:smart_auth/smart_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isNavigating = false;
  bool _hasNavigatedToOTP = false;
  String? _pendingMobileNumber;
  bool hidePhoneHint = false;
  final smartAuth = SmartAuth.instance;

  // Input type detection
  InputType _inputType = InputType.unknown;


  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Listen for input changes to detect type
    _identifierController.addListener(_detectInputType);

    // ✅ NEW: Request SMS permission silently
    _requestSmsPermissionSilently();
  }

  @override
  void dispose() {
    _identifierController.removeListener(_detectInputType);
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestSmsPermissionSilently() async {
    try {
      // Use existing SmsOtpService to request permission
      final smsService = SmsOtpService();
      await smsService.requestSmsPermissions();
      debugPrint('📱 SMS permission requested silently');
    } catch (e) {
      debugPrint('⚠️ SMS permission request failed: $e');
      // Continue silently - don't show any error to user
    }
  }

  void _detectInputType() {
    final input = _identifierController.text.trim();
    InputType newType;

    if (input.isEmpty) {
      newType = InputType.unknown;
    } else if (input.contains('@')) {
      newType = InputType.email;
    } else if (RegExp(r'^[0-9]+$').hasMatch(input)) {
      newType = InputType.phone;
    } else if (RegExp(r'^[a-zA-Z0-9.]+$').hasMatch(input)) {
      newType = InputType.potential_email;
    } else {
      newType = InputType.unknown;
    }

    if (newType != _inputType) {
      setState(() {
        _inputType = newType;
      });
    }
  }

  void _attemptLogin() {
    debugPrint('🔄 _attemptLogin called - isNavigating: $_isNavigating');

    if (_isNavigating) {
      debugPrint('❌ Prevented double navigation attempt');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('✅ Form validation passed, setting isNavigating to true');
      setState(() {
        _isNavigating = true;
        _hasNavigatedToOTP = false;
      });

      if (_inputType == InputType.email ||
          _inputType == InputType.potential_email) {
        debugPrint(
          '📧 Attempting email login for: ${_identifierController.text.trim()}',
        );
        context.read<AuthCubit>().login(
          _identifierController.text.trim(),
          _passwordController.text,
        );
      } else if (_inputType == InputType.phone) {
        final mobileNumber = _identifierController.text.trim();
        debugPrint('📱 Requesting OTP for: $mobileNumber');
        _pendingMobileNumber = mobileNumber;
        context.read<AuthCubit>().requestLoginOTP(mobileNumber);
      }
    } else {
      debugPrint('❌ Form validation failed');
    }
  }

  void _demoLogin() {
    debugPrint('🎮 Demo login attempted');
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
      _hasNavigatedToOTP = false;
      _pendingMobileNumber = null;
    });
    context.read<AuthCubit>().demoLogin();
  }

  void _forgotPassword() {
    Navigator.of(context).pushNamed(AppRouter.forgotPasswordRoute);
  }

  void _navigateAfterAuth(AuthAuthenticated state) {
    debugPrint(
      '🧭 LoginScreen navigating after auth - NeedsCompletion: ${state.needsProfileCompletion}',
    );

    if (state.needsProfileCompletion) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileCompletionScreen(user: state.user),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.mainRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          debugPrint(
            '🎯 LoginScreen BlocListener - State: ${state.runtimeType}',
          );

          if (state is AuthAuthenticated) {
            _navigateAfterAuth(state);
          } else if (state is AuthError) {
            debugPrint('❌ AuthError: ${state.message}');
            setState(() {
              _isNavigating = false;
              _hasNavigatedToOTP = false;
              _pendingMobileNumber = null;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthOTPSent) {
            debugPrint('📨 AuthOTPSent - navigating to OTP screen');

            if (!_hasNavigatedToOTP &&
                _pendingMobileNumber != null &&
                _pendingMobileNumber!.isNotEmpty) {
              setState(() => _hasNavigatedToOTP = true);

              Navigator.of(context)
                  .pushNamed(
                    AppRouter.verifyOtpRoute,
                    arguments: {
                      'mobile': _pendingMobileNumber!,
                      'isRegistration': false,
                    },
                  )
                  .then((_) {
                    setState(() {
                      _isNavigating = false;
                      _hasNavigatedToOTP = false;
                      _pendingMobileNumber = null;
                    });
                  });
            }
          } else if (state is AuthRegistrationSuccess) {
            setState(() {
              _isNavigating = false;
              _hasNavigatedToOTP = false;
              _pendingMobileNumber = null;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is! AuthLoading) {
            setState(() {
              _isNavigating = false;
              _hasNavigatedToOTP = false;
              _pendingMobileNumber = null;
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.marginLarge),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App logo/animation
                        Lottie.asset('assets/lottie/login_bike.json'),
                        const SizedBox(height: AppDimensions.marginLarge),
                        Text(
                          'Welcome to Tiffin Dost',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Your meal subscription service',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppDimensions.marginExtraLarge),

                        // Smart identifier field with SIM picker
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _identifierController,
                              decoration: InputDecoration(
                                labelText: 'Email or Phone Number',
                                hintText: 'Enter your email or phone number',
                                prefixIcon: Icon(_getIdentifierIcon()),
                              ),
                              keyboardType: _inputType == InputType.phone
                                  ? TextInputType.phone
                                  : TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: _validateIdentifier,
                              onTap: () async {
                                if (hidePhoneHint == false) {
                                  final res = await smartAuth.requestPhoneNumberHint();
                                  if (res.hasData) {
                                    setState(() {
                                      String phoneNumber = res.data!;
                                      String number = phoneNumber.substring(phoneNumber.length - 10);
                                      _identifierController.text = number;
                                      hidePhoneHint = true;
                                    });
                                  } else {
                                    hidePhoneHint = true;
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Password field for email login
                        if (_inputType == InputType.email ||
                            _inputType == InputType.potential_email)
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _attemptLogin(),
                          ),

                        const SizedBox(height: AppDimensions.marginSmall),
                        if (_inputType == InputType.email ||
                            _inputType == InputType.potential_email)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Forgot Password?'),
                            ),
                          ),

                        const SizedBox(height: AppDimensions.marginLarge),
                        PrimaryButton(
                          text: _getActionButtonText(),
                          onPressed: _attemptLogin,
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        // SecondaryButton(
                        //   text: 'Demo Login',
                        //   onPressed: state is AuthLoading ? null : _demoLogin,
                        //   icon: Icons.play_arrow,
                        // ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        TextButton(
                          onPressed:
                              state is AuthLoading
                                  ? null
                                  : () {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(AppRouter.registerRoute);
                                  },
                          child: const Text('Don\'t have an account? Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIdentifierIcon() {
    switch (_inputType) {
      case InputType.email:
        return Icons.email_outlined;
      case InputType.phone:
        return Icons.phone;
      case InputType.potential_email:
        return Icons.email_outlined;
      default:
        return Icons.person_outline;
    }
  }

  String _getActionButtonText() {
    if (_inputType == InputType.phone) {
      return 'Send OTP';
    } else {
      return 'Login';
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }

    final trimmedValue = value.trim();

    if (_inputType == InputType.email) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedValue)) {
        return 'Please enter a valid email';
      }
    } else if (_inputType == InputType.phone) {
      return _validatePhone(trimmedValue);
    }

    return null;
  }

  String? _validatePhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length != 10) {
      return 'Please enter a 10-digit mobile number';
    }

    if (!digits.startsWith(RegExp(r'[6-9]'))) {
      return 'Please enter a valid Indian mobile number';
    }

    return null;
  }
}

enum InputType { unknown, email, potential_email, phone }
