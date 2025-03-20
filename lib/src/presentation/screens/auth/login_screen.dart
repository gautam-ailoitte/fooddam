// lib/src/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/responsive_layout.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/validation/form_controller.dart';
import 'package:foodam/core/validation/form_validarot.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_text_field.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FormController _formController = FormController();
  bool _isObscure = true;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: ResponsiveBuilder(
              builder: (context, screenInfo) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenInfo.isMobile ? 24.0 : screenInfo.widthPx * 0.1,
                      ),
                      child: _buildLoginForm(context, state),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthState state) {
    return Form(
      key: _formController.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo and Header
          _buildHeader(),
          
          AppSpacing.vLg,
          
          // Email Field
          AppTextField(
            controller: _formController.controller('email'),
            label: StringConstants.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => FormValidator.required(value, message: StringConstants.emailRequired) ?? 
                                FormValidator.email(value, message: StringConstants.invalidEmail),
            prefix: const Icon(Icons.email_outlined),
            focusNode: _formController.focusNode('email'),
            onSubmitted: (_) => _formController.nextField('email', 'password'),
          ),
          
          AppSpacing.vMd,
          
          // Password Field
          AppTextField(
            controller: _formController.controller('password'),
            label: StringConstants.password,
            obscureText: _isObscure,
            validator: (value) => FormValidator.required(value, message: StringConstants.passwordRequired) ??
                                FormValidator.minLength(value, 6, message: StringConstants.passwordTooShort),
            prefix: const Icon(Icons.lock_outline),
            suffix: IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            ),
            focusNode: _formController.focusNode('password'),
            onSubmitted: (_) => _login(),
          ),
          
          AppSpacing.vSm,
          
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Implement forgot password
              },
              child: Text(
                StringConstants.forgotPassword,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          AppSpacing.vXl,
          
          // Login Button
          if (state is AuthLoading)
            const AppLoading(message: StringConstants.loggingIn)
          else
            AppButton(
              label: StringConstants.login,
              onPressed: _login,
              isFullWidth: true,
              buttonType: AppButtonType.primary,
              buttonSize: AppButtonSize.large,
            ),
          
          AppSpacing.vLg,
          
          // Demo Login Button
          AppButton(
            label: StringConstants.demoLogin,
            onPressed: _demoLogin,
            isFullWidth: true,
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.large,
          ),
          
          if (state is AuthError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                state.message,
                style: TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.vMd,
        // App Title
        Text(
          StringConstants.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.vSm,
        // Tag line
        Text(
          "Delicious meals delivered to your doorstep",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _login() {
    if (_formController.validate()) {
      final email = _formController.getValue('email')!;
      final password = _formController.getValue('password')!;
      
      context.read<AuthCubit>().login(email, password);
    }
  }

  void _demoLogin() {
    context.read<AuthCubit>().login('johndoe@example.com', 'password');
  }
}