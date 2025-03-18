// lib/src/presentation/screens/auth/login_screen.dart
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
import 'package:foodam/src/presentation/screens/auth/register_screen.dart';
import 'package:foodam/src/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formController = FormController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _login() {
    if (_formController.validate()) {
      final email = _formController.getValue('email') ?? '';
      final password = _formController.getValue('password') ?? '';

      context.read<AuthCubit>().login(email, password);
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.login,
      hasBackButton: false,
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
            return const AppLoading(message: StringConstants.loggingIn);
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo placeholder
                  const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.orange,
                  ),
                  AppSpacing.vLg,
                  
                  // Title
                  Text(
                    StringConstants.login,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vLg,
                  
                  // Email field
                  AppTextField(
                    controller: _formController.controller('email'),
                    label: StringConstants.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: FieldValidators.email(),
                    prefix: const Icon(Icons.email),
                  ),
                  AppSpacing.vMd,
                  
                  // Password field
                  AppTextField(
                    controller: _formController.controller('password'),
                    label: StringConstants.password,
                    obscureText: !_isPasswordVisible,
                    validator: FieldValidators.required(),
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
                  AppSpacing.vSm,
                  
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(StringConstants.forgotPassword),
                    ),
                  ),
                  AppSpacing.vLg,
                  
                  // Login button
                  AppButton(
                    label: StringConstants.login,
                    onPressed: _login,
                    buttonType: AppButtonType.primary,
                    buttonSize: AppButtonSize.large,
                  ),
                  AppSpacing.vLg,
                  
                  // Register prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                  
                  // Demo login (for development)
                  if (true) // Set to false in production
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: AppButton(
                        label: StringConstants.demoLogin,
                        onPressed: () {
                          context.read<AuthCubit>().login(
                                'john.doe@example.com',
                                'password123',
                              );
                        },
                        buttonType: AppButtonType.outline,
                        buttonSize: AppButtonSize.medium,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}