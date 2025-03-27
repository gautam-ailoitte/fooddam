// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/core/widgets/secondary_button.dart';
import 'package:foodam/firebase_seed.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _attemptLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }
  
  void _demoLogin() {
    context.read<AuthCubit>().demoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed(AppRouter.mainRoute);
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
                        // FoodamLogo(size: 120),
                             Lottie.asset('assets/lottie/login_bike.json'),
                        SizedBox(height: AppDimensions.marginLarge),
                        Text(
                          'Welcome to Foodam',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          'Your meal subscription service',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: AppDimensions.marginExtraLarge),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.marginMedium),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outlined),
                          ),
                          obscureText: true,
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
                        SizedBox(height: AppDimensions.marginLarge),
                        PrimaryButton(
                          text: 'Login',
                          onPressed: _attemptLogin,
                          isLoading: state is AuthLoading,
                        ),
                        SizedBox(height: AppDimensions.marginMedium),
                        SecondaryButton(
                          text: 'Demo Login',
                          onPressed: state is AuthLoading ? null : _demoLogin,
                          icon: Icons.play_arrow,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          ;
        },
      ),
      // bottomNavigationBar:buildSeedButton(context),
    );
  }


  FloatingActionButton buildSeedButton(BuildContext context) {
  return FloatingActionButton(
    heroTag: 'seedingFab',
    onPressed: () => _showSeedingDialog(context),
    backgroundColor: Colors.amber,
    tooltip: 'Seed Firebase Database',
    child: const Icon(Icons.data_array),
  );
}

// Add these methods in your screen class or in a utility file
Future<void> _showSeedingDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Seed Firebase Database'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This will populate the Firebase database with test data.'),
          SizedBox(height: 10),
          Text(
            'Test login credentials after seeding will be:\n'
            'Email: johndoe@example.com\n'
            'Password: password'
          ),
          SizedBox(height: 10),
          Text('Would you like to proceed with seeding?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _performSeeding(context);
          },
          child: const Text('Seed Database'),
        ),
      ],
    ),
  );
}

Future<void> _performSeeding(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final logger = LoggerService(); // You may need to adjust this based on your logger implementation
  
  // Show loading indicator
  scaffoldMessenger.showSnackBar(
    const SnackBar(
      content: Text('Seeding Firebase database... This may take a moment.'),
      duration: Duration(seconds: 2),
    ),
  );
  
  try {
    logger.i('Starting database seeding', tag: 'FIREBASE_SEED');
    
    // Perform seeding
    await FirebaseSeed.seedDatabase();
    
    logger.i('Database seeding completed successfully', tag: 'FIREBASE_SEED');
    
    // Show success message
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Firebase database successfully seeded with test data.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ),
    );
  } catch (e) {
    logger.e('Error seeding database', error: e, tag: 'FIREBASE_SEED');
    
    // Show error message
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Error seeding Firebase database: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}