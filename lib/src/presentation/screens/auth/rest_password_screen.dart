// lib/src/presentation/screens/auth/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:lottie/lottie.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _resetComplete = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().resetPassword(
        widget.resetToken,
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set New Password'), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            // Password reset was successful, showing success view
            setState(() {
              _resetComplete = true;
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.marginLarge),
                child:
                    _resetComplete
                        ? _buildSuccessContent()
                        : _buildResetForm(state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetForm(AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/animation
          Lottie.asset('assets/lottie/login_bike.json', height: 160),
          const SizedBox(height: AppDimensions.marginLarge),
          Text(
            'Create New Password',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Enter and confirm your new password',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginExtraLarge),

          // New password field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onFieldSubmitted: (_) => _resetPassword(),
          ),

          const SizedBox(height: AppDimensions.marginLarge),

          PrimaryButton(
            text: 'Reset Password',
            onPressed: _resetPassword,
            isLoading: state is AuthLoading,
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          TextButton(
            onPressed:
                state is AuthLoading
                    ? null
                    : () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.loginRoute,
                        (route) => false,
                      );
                    },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppDimensions.marginLarge),
        Text(
          'Password Reset Successful',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Text(
          'Your password has been reset successfully. You can now log in with your new password.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.marginExtraLarge),
        PrimaryButton(
          text: 'Go to Login',
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRouter.loginRoute, (route) => false);
          },
        ),
      ],
    );
  }
}
