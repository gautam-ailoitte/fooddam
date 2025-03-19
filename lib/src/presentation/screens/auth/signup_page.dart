// lib/src/presentation/pages/auth/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/validation/form_controller.dart';
import 'package:foodam/core/validation/form_field_validator.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_text_field.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/screens/home/home_page.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formController = FormController();
  bool _obscurePassword = true;
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _formController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _nextPage() {
    if (_currentPage == 0) {
      // Validate personal info
      if (_validatePersonalInfo()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = 1;
        });
      }
    } else if (_currentPage == 1) {
      // Validate address info
      if (_validateAddressInfo()) {
        _handleRegister();
      }
    }
  }

  bool _validatePersonalInfo() {
    final fields = ['firstName', 'lastName', 'email', 'phone', 'password'];
    bool isValid = true;

    for (final field in fields) {
      final validator = _formController.formKey.currentState?.validate() ?? false;
      if (!validator) {
        isValid = false;
      }
    }

    return isValid;
  }

  bool _validateAddressInfo() {
    final fields = ['street', 'city', 'state', 'zipCode', 'country'];
    bool isValid = true;

    for (final field in fields) {
      final validator = _formController.formKey.currentState?.validate() ?? false;
      if (!validator) {
        isValid = false;
      }
    }

    return isValid;
  }

  void _handleRegister() {
    if (_formController.validate()) {
      final firstName = _formController.getValue('firstName') ?? '';
      final lastName = _formController.getValue('lastName') ?? '';
      final email = _formController.getValue('email') ?? '';
      final phone = _formController.getValue('phone') ?? '';
      final password = _formController.getValue('password') ?? '';

      // Create address
      final address = Address(
        street: _formController.getValue('street') ?? '',
        city: _formController.getValue('city') ?? '',
        state: _formController.getValue('state') ?? '',
        zipCode: _formController.getValue('zipCode') ?? '',
        country: _formController.getValue('country') ?? '',
      );

      // Register user
      context.read<AuthCubit>().register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            phone: phone,
            address: address,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed(HomePage.routeName);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          title: 'Create Account',
          type: ScaffoldType.withAppBar,
          body: Form(
            key: _formController.formKey,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoPage(context, state),
                _buildAddressInfoPage(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPersonalInfoPage(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.vMd,
          AppCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _formController.controller('firstName'),
                  label: 'First Name',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.person_outline),
                  onSubmitted: (_) => _formController.focus('lastName'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('lastName'),
                  label: 'Last Name',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.person_outline),
                  onSubmitted: (_) => _formController.focus('email'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('email'),
                  label: StringConstants.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: FieldValidators.email(),
                  prefix: const Icon(Icons.email_outlined),
                  onSubmitted: (_) => _formController.focus('phone'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('phone'),
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  validator: FieldValidators.phone(),
                  prefix: const Icon(Icons.phone_outlined),
                  onSubmitted: (_) => _formController.focus('password'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('password'),
                  label: StringConstants.password,
                  obscureText: _obscurePassword,
                  validator: FieldValidators.password(
                    requireSpecialChars: false,
                    requireUppercase: false,
                    minLength: 6,
                  ),
                  prefix: const Icon(Icons.lock_outline),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  onSubmitted: (_) => _nextPage(),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          AppButton(
            label: 'Next',
            onPressed: _nextPage,
            buttonType: AppButtonType.primary,
            trailingIcon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoPage(BuildContext context, AuthState state) {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.vMd,
          AppCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _formController.controller('street'),
                  label: 'Street Address',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.home_outlined),
                  onSubmitted: (_) => _formController.focus('city'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('city'),
                  label: 'City',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.location_city_outlined),
                  onSubmitted: (_) => _formController.focus('state'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('state'),
                  label: 'State/Province',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.map_outlined),
                  onSubmitted: (_) => _formController.focus('zipCode'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('zipCode'),
                  label: 'ZIP/Postal Code',
                  validator: FieldValidators.required(),
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.pin_outlined),
                  onSubmitted: (_) => _formController.focus('country'),
                ),
                AppSpacing.vMd,
                AppTextField(
                  controller: _formController.controller('country'),
                  label: 'Country',
                  validator: FieldValidators.required(),
                  prefix: const Icon(Icons.public_outlined),
                  onSubmitted: (_) => _nextPage(),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Back',
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _currentPage = 0;
                    });
                  },
                  buttonType: AppButtonType.outline,
                  leadingIcon: Icons.arrow_back,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: AppButton(
                  label: 'Register',
                  onPressed: _nextPage,
                  isLoading: state.isLoading,
                  buttonType: AppButtonType.primary,
                  trailingIcon: Icons.check,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}