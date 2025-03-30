// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _otpRequested = false;
  
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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
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
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _detectInputType() {
    final input = _identifierController.text;
    InputType newType;
    
    if (input.isEmpty) {
      newType = InputType.unknown;
    } else if (RegExp(r'^[0-9]+$').hasMatch(input)) {
      // Contains only numbers - likely a phone number
      newType = InputType.phone;
    } else if (input.contains('@')) {
      // Contains @ - likely an email
      newType = InputType.email;
    } else if (RegExp(r'^[a-zA-Z0-9.]+$').hasMatch(input)) {
      // Contains letters, numbers, or dots - could be starting an email
      newType = InputType.potential_email;
    } else {
      // Something else
      newType = InputType.unknown;
    }
    
    if (newType != _inputType) {
      setState(() {
        _inputType = newType;
        // Reset OTP requested state if input type changes
        if (newType != InputType.phone) {
          _otpRequested = false;
        }
      });
    }
  }

  void _requestOtp() {
    // Here you would integrate with your OTP sending mechanism
    // For now, we'll just simulate the UI flow
    setState(() {
      _otpRequested = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP sent to ${_identifierController.text}!')),
    );
  }

  void _attemptLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_inputType == InputType.email || _inputType == InputType.potential_email) {
        context.read<AuthCubit>().login(
          _identifierController.text,
          _passwordController.text,
        );
      } else if (_inputType == InputType.phone) {
        if (_otpRequested) {
          // Implement OTP verification here
          // For now, we'll just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP login will be available soon')),
          );
        } else {
          _requestOtp();
        }
      }
    }
  }
  
  void _demoLogin() {
    context.read<AuthCubit>().demoLogin();
  }

  void _forgotPassword() {
    Navigator.of(context).pushNamed(AppRouter.forgotPasswordRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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
                          keyboardType: _inputType == InputType.phone 
                              ? TextInputType.phone 
                              : TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateIdentifier,
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        
                        // Conditional fields based on input type
                        if (_inputType == InputType.email || _inputType == InputType.potential_email) 
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
                          )
                        else if (_inputType == InputType.phone && _otpRequested)
                          // OTP field only shown after requesting OTP
                          TextFormField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'OTP',
                              prefixIcon: Icon(Icons.pin),
                              hintText: 'Enter the OTP sent to your phone',
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the OTP';
                              }
                              if (!RegExp(r'^[0-9]{4,6}$').hasMatch(value)) {
                                return 'Please enter a valid OTP';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _attemptLogin(),
                          ),
                        
                        const SizedBox(height: AppDimensions.marginSmall),
                        if (_inputType == InputType.email || _inputType == InputType.potential_email)
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
                          onPressed: state is AuthLoading ? null : () {
                            Navigator.of(context).pushNamed(AppRouter.registerRoute);
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
      return _otpRequested ? 'Verify OTP' : 'Send OTP';
    } else {
      return 'Login';
    }
  }
  
  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email or phone number';
    }
    
    if (_inputType == InputType.email) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
        return 'Please enter a valid email';
      }
    } else if (_inputType == InputType.phone) {
      if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    
    return null;
  }
}

// Input type enum for better type checking
enum InputType {
  unknown,
  email,
  potential_email,
  phone,
}