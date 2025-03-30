// lib/src/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:lottie/lottie.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _resetEmailSent = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().forgotPassword(_emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            setState(() {
              _resetEmailSent = true;
            });
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
                child: _resetEmailSent ? _buildSuccessContent() : _buildResetForm(state),
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
          Lottie.asset(
            'assets/lottie/login_bike.json',
            height: 160,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          Text(
            'Reset Password',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Enter your email address to receive a password reset link',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginExtraLarge),
          
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _resetPassword(),
          ),
          
          const SizedBox(height: AppDimensions.marginLarge),
          PrimaryButton(
            text: 'Send Reset Link',
            onPressed: _resetPassword,
            isLoading: state is AuthLoading,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          TextButton(
            onPressed: state is AuthLoading ? null : () {
              Navigator.of(context).pop();
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
          'Email Sent',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppDimensions.marginSmall),
        Text(
          'If a user with that email exists, a password reset link has been sent',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.marginExtraLarge),
        PrimaryButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).popUntil(
              ModalRoute.withName(AppRouter.loginRoute),
            );
          },
        ),
      ],
    );
  }
}