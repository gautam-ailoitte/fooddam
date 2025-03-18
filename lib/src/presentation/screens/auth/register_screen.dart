// lib/src/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/validation/form_controller.dart';
import 'package:foodam/core/validation/form_field_validator.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_text_field.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formController = FormController();
  bool _isPasswordVisible = false;
  final _scrollController = ScrollController();
  
  // Track current form section
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _formController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _nextStep() {
    // Validate current step
    final isValid = _validateCurrentStep();
    
    if (isValid) {
      setState(() {
        _currentStep = (_currentStep + 1).clamp(0, _totalSteps - 1);
      });
      
      // Scroll to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = (_currentStep - 1).clamp(0, _totalSteps - 1);
    });
    
    // Scroll to top
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Basic info validation
        return _formController.validate();
      case 1:
        // Contact info validation
        return _formController.validate();
      case 2:
        // Address validation
        return _formController.validate();
      default:
        return false;
    }
  }

  void _register() {
    if (_validateCurrentStep()) {
      final firstName = _formController.getValue('firstName') ?? '';
      final lastName = _formController.getValue('lastName') ?? '';
      final email = _formController.getValue('email') ?? '';
      final password = _formController.getValue('password') ?? '';
      final phone = _formController.getValue('phone') ?? '';
      final street = _formController.getValue('street') ?? '';
      final city = _formController.getValue('city') ?? '';
      final state = _formController.getValue('state') ?? '';
      final zipCode = _formController.getValue('zipCode') ?? '';
      
      context.read<AuthCubit>().register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        street: street,
        city: city,
        state: state,
        zipCode: zipCode,
        country: 'India', // Default for now
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register',
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const AppLoading(message: 'Creating your account...');
          }

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              
              // Form content
              Form(
                key: _formController.formKey,
                child: _buildCurrentStep(),
              ),
              
              AppSpacing.vLg,
              
              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: AppButton(
                        label: 'Previous',
                        onPressed: _previousStep,
                        buttonType: AppButtonType.outline,
                        buttonSize: AppButtonSize.medium,
                      ),
                    ),
                  if (_currentStep > 0) AppSpacing.hMd,
                  Expanded(
                    child: AppButton(
                      label: _currentStep < _totalSteps - 1 ? 'Next' : 'Register',
                      onPressed: _currentStep < _totalSteps - 1 ? _nextStep : _register,
                      buttonType: AppButtonType.primary,
                      buttonSize: AppButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildContactInfoStep();
      case 2:
        return _buildAddressStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('firstName'),
          label: 'First Name',
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.person),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('lastName'),
          label: 'Last Name',
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.person),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('email'),
          label: StringConstants.email,
          keyboardType: TextInputType.emailAddress,
          validator: FieldValidators.email(),
          prefix: const Icon(Icons.email),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('password'),
          label: StringConstants.password,
          obscureText: !_isPasswordVisible,
          validator: FieldValidators.password(
            minLength: 6,
            requireSpecialChars: false,
            requireUppercase: false,
          ),
          prefix: const Icon(Icons.lock),
          suffix: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('phone'),
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: FieldValidators.phone(),
          prefix: const Icon(Icons.phone),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('street'),
          label: 'Street Address',
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.home),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('city'),
          label: 'City',
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.location_city),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('state'),
          label: 'State',
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.map),
        ),
        AppSpacing.vMd,
        AppTextField(
          controller: _formController.controller('zipCode'),
          label: 'ZIP Code',
          keyboardType: TextInputType.number,
          validator: FieldValidators.required(),
          prefix: const Icon(Icons.pin_drop),
        ),
      ],
    );
  }
}