// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/widgets/secondary_button.dart';

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
  bool _isNavigating = false; // Prevent double navigation
  bool _hasNavigatedToOTP = false; // NEW: Prevent duplicate OTP navigation
  String? _pendingMobileNumber; // NEW: Store mobile number for OTP

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
  }

  @override
  void dispose() {
    _identifierController.removeListener(_detectInputType);
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _detectInputType() {
    final input = _identifierController.text.trim();
    InputType newType;

    if (input.isEmpty) {
      newType = InputType.unknown;
    } else if (input.contains('@')) {
      // Check email first since @ is definitive
      newType = InputType.email;
    } else if (RegExp(r'^[0-9]+$').hasMatch(input)) {
      // Contains only numbers - phone number
      newType = InputType.phone;
    } else if (RegExp(r'^[a-zA-Z0-9.]+$').hasMatch(input)) {
      // Contains letters, numbers, or dots - could be starting an email
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
    debugPrint('🔄 _attemptLogin called - isNavigating: $_isNavigating, hasNavigatedToOTP: $_hasNavigatedToOTP');

    if (_isNavigating) {
      debugPrint('❌ Prevented double navigation attempt');
      return; // Prevent double navigation
    }

    if (_formKey.currentState?.validate() ?? false) {
      debugPrint('✅ Form validation passed, setting isNavigating to true');
      setState(() {
        _isNavigating = true;
        _hasNavigatedToOTP = false; // Reset OTP navigation flag
      });

      if (_inputType == InputType.email || _inputType == InputType.potential_email) {
        debugPrint('📧 Attempting email login for: ${_identifierController.text.trim()}');
        context.read<AuthCubit>().login(
          _identifierController.text.trim(),
          _passwordController.text,
        );
      } else if (_inputType == InputType.phone) {
        final mobileNumber = _identifierController.text.trim();
        debugPrint('📱 Requesting OTP for: $mobileNumber');

        // Store mobile number to prevent loss during state changes
        _pendingMobileNumber = mobileNumber;

        context.read<AuthCubit>().requestLoginOTP(mobileNumber);
      }
    } else {
      debugPrint('❌ Form validation failed');
    }
  }

  void _demoLogin() {
    debugPrint('🎮 Demo login attempted - isNavigating: $_isNavigating');
    if (_isNavigating) {
      debugPrint('❌ Prevented double demo login attempt');
      return;
    }
    debugPrint('✅ Proceeding with demo login');
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
    debugPrint('🧭 LoginScreen navigating after auth - NeedsCompletion: ${state.needsProfileCompletion}');

    if (state.needsProfileCompletion) {
      debugPrint('📝 LoginScreen navigating to profile completion');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProfileCompletionScreen(user: state.user),
        ),
      );
    } else {
      debugPrint('🏠 LoginScreen navigating to main screen');
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.mainRoute,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          debugPrint('🎯 LoginScreen BlocListener - State: ${state.runtimeType}');
          debugPrint('🔍 Current isNavigating: $_isNavigating, hasNavigatedToOTP: $_hasNavigatedToOTP');

          if (state is AuthAuthenticated) {
            debugPrint('✅ AuthAuthenticated received - navigating to main/profile');
            _navigateAfterAuth(state);
          } else if (state is AuthError) {
            debugPrint('❌ AuthError: ${state.message}');
            setState(() {
              _isNavigating = false;
              _hasNavigatedToOTP = false;
              _pendingMobileNumber = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthOTPSent) {
            debugPrint('📨 AuthOTPSent - navigating to OTP screen');
            debugPrint('📱 Stored mobile number: $_pendingMobileNumber');
            debugPrint('📱 Controller mobile number: ${_identifierController.text.trim()}');

            // Only navigate once using stored mobile number
            if (!_hasNavigatedToOTP && _pendingMobileNumber != null && _pendingMobileNumber!.isNotEmpty) {
              debugPrint('🚀 First AuthOTPSent - proceeding with navigation');
              setState(() => _hasNavigatedToOTP = true);

              Navigator.of(context).pushNamed(
                AppRouter.verifyOtpRoute,
                arguments: {
                  'mobile': _pendingMobileNumber!,
                  'isRegistration': false,
                },
              ).then((_) {
                debugPrint('🔙 Returned from OTP screen');
                setState(() {
                  _isNavigating = false;
                  _hasNavigatedToOTP = false;
                  _pendingMobileNumber = null;
                });
              });
            } else {
              debugPrint('⚠️ Duplicate AuthOTPSent ignored - already navigated or no mobile number');
              debugPrint('   hasNavigatedToOTP: $_hasNavigatedToOTP');
              debugPrint('   pendingMobileNumber: $_pendingMobileNumber');
            }
          } else if (state is AuthRegistrationSuccess) {
            debugPrint('🎉 Registration success: ${state.message}');
            setState(() {
              _isNavigating = false;
              _hasNavigatedToOTP = false;
              _pendingMobileNumber = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthLoading) {
            debugPrint('⏳ AuthLoading state - maintaining navigation flags');
            // Don't reset navigation flags during loading
          } else {
            debugPrint('🔄 Other state: ${state.runtimeType} - resetting navigation flags');
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
                          'Welcome to Foodam',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Your meal subscription service',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppDimensions.marginExtraLarge),

                        // Smart dynamic identifier field
                        TextFormField(
                          controller: _identifierController,
                          decoration: InputDecoration(
                            labelText: 'Email or Phone Number',
                            hintText: 'Enter your email or phone number',
                            prefixIcon: Icon(_getIdentifierIcon()),
                          ),
                          keyboardType:
                          _inputType == InputType.phone
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateIdentifier,
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Conditional fields based on input type
                        if (_inputType == InputType.email ||
                            _inputType == InputType.potential_email)
                        // Password field for email login
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
                        SecondaryButton(
                          text: 'Demo Login',
                          onPressed: state is AuthLoading ? null : _demoLogin,
                          icon: Icons.play_arrow,
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        TextButton(
                          onPressed:
                          state is AuthLoading
                              ? null
                              : () {
                            Navigator.of(context).pushNamed(
                              AppRouter.registerRoute,
                            );
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

  // Helper methods for UI logic
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

// Input type enum for better type checking
enum InputType {
  unknown,
  email,
  // ignore: constant_identifier_names
  potential_email,
  phone,
}