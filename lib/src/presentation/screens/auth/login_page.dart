// lib/src/presentation/pages/auth/login_page.dart
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
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/screens/auth/signup_page.dart';
import 'package:foodam/src/presentation/screens/home/home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formController = FormController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() {
    if (_formController.validate()) {
      final email = _formController.getValue('email') ?? '';
      final password = _formController.getValue('password') ?? '';

      context.read<AuthCubit>().login(email, password);
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
              content: Text(state.errorMessage ?? StringConstants.loginFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return AppScaffold(
          type: ScaffoldType.basic,
          body: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 80,
                  ),
                  AppSpacing.vMd,
                  Text(
                    StringConstants.appTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vLg,
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formController.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            StringConstants.login,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          AppSpacing.vMd,
                          AppTextField(
                            controller: _formController.controller('email'),
                            label: StringConstants.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: FieldValidators.email(),
                            inputFormatters: const [],
                            prefix: const Icon(Icons.email_outlined),
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
                            onSubmitted: (_) => _handleLogin(),
                          ),
                          AppSpacing.vSm,
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Navigate to forgot password page
                              },
                              child: Text(StringConstants.forgotPassword),
                            ),
                          ),
                          AppSpacing.vMd,
                          AppButton(
                            label: StringConstants.login,
                            onPressed: _handleLogin,
                            isLoading: state.isLoading,
                            buttonType: AppButtonType.primary,
                            leadingIcon: Icons.login,
                          ),
                          AppSpacing.vMd,
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(RegisterPage.routeName);
                              },
                              child: const Text('Don\'t have an account? Sign up'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}