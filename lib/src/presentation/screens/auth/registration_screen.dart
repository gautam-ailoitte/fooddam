// lib/src/presentation/screens/auth/registration_screen.dart
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/screens/profile/profile_completion_screen.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  
  // Registration flow
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
    _phoneController.dispose();
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
        
        // If type changes to phone, copy value to phone controller
        if (newType == InputType.phone) {
          _phoneController.text = input;
        }
        
        // Reset OTP requested state if input type changes
        if (newType != InputType.phone) {
          _otpRequested = false;
        }
      });
    }
  }
  
  void _requestOtp() {
    // Here you would integrate with your OTP sending mechanism
    setState(() {
      _otpRequested = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OTP sent to ${_identifierController.text}!')),
    );
  }

  void _attemptRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the terms and conditions')),
        );
        return;
      }
      
      if (_inputType == InputType.email || _inputType == InputType.potential_email) {
        // Register with email and password
        context.read<AuthCubit>().register(
          _identifierController.text,
          _passwordController.text,
          _phoneController.text,
          _acceptTerms,
        );
      } else if (_inputType == InputType.phone) {
        if (_otpRequested) {
          // Implement OTP verification and registration
          // For now, we'll just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP registration will be available soon')),
          );
        } else {
          _requestOtp();
        }
      }
    }
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
                        Lottie.asset(
                          'assets/lottie/login_bike.json',
                          height: 160,
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Join Foodam meal subscription service',
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
                        if (_inputType == InputType.email || _inputType == InputType.potential_email) ...[
                          // Password field for email registration
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
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),
                          
                          // Phone field for email registration (as additional field)
                          if (_identifierController.text.contains('@'))
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                        ] else if (_inputType == InputType.phone) ...[
                          // Only show verification message initially
                          if (!_otpRequested)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'We will send an OTP to this number for verification',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          // OTP field only shown after requesting OTP
                          if (_otpRequested)
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
                            ),
                        ],
                        
                        const SizedBox(height: AppDimensions.marginMedium),
                        
                        // Terms and conditions checkbox
                        CheckboxListTile(
                          title: const Text('I accept the Terms and Conditions'),
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        
                        const SizedBox(height: AppDimensions.marginLarge),
                        PrimaryButton(
                          text: _getActionButtonText(),
                          onPressed: _attemptRegister,
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Go back to login screen
                          },
                          child: const Text('Already have an account? Login'),
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
      return _otpRequested ? 'Verify & Register' : 'Send OTP';
    } else {
      return 'Register';
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

// Input type enum (same as in login screen)
enum InputType {
  unknown,
  email,
  potential_email,
  phone,
}