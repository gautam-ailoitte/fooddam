// lib/src/presentation/screens/splash/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/navigation_service.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Start the animation
    _animationController.forward();
    
    // Add a delay before checking auth status
    Timer(const Duration(milliseconds: 3500), () {
      // Navigate based on auth state
      final authState = BlocProvider.of<AuthCubit>(context).state;
      _navigateBasedOnAuthState(authState);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateBasedOnAuthState(AuthState state) {
    if (state is AuthAuthenticated) {
      NavigationService.pushReplacementNamed(AppRoutes.home);
    } else if (state is AuthUnauthenticated) {
      NavigationService.pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _navigateBasedOnAuthState(state);
        }
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.9),
                    AppColors.primaryDark,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top decorative elements
                    Expanded(
                      flex: 2,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildTopDecoration(),
                      ),
                    ),
                    
                    // Logo and app name section
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App icon with animations
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: _buildLogoContainer(),
                              ),
                            ),
                          ),
                          
                          AppSpacing.vLg,
                          
                          // App name
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              StringConstants.appTitle,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          
                          AppSpacing.vSm,
                          
                          // App tagline
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              "Delicious homemade meals, delivered daily",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Loading indicator and status text
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Progress indicator
                          const AppLoading(
                            color: Colors.white,
                            size: 32,
                            strokeWidth: 3,
                          ),
                          
                          AppSpacing.vMd,
                          
                          // Status text
                          Text(
                            StringConstants.startingApp,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Plate background
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 3,
                ),
              ),
            ),
            
            // Food icon
            Icon(
              Icons.restaurant_menu,
              size: 50,
              color: AppColors.primary,
            ),
            
            // Decorative elements
            Positioned(
              right: 20,
              top: 20,
              child: Icon(
                Icons.breakfast_dining,
                size: 22,
                color: AppColors.accent,
              ),
            ),
            
            Positioned(
              left: 20,
              bottom: 20,
              child: Icon(
                Icons.lunch_dining,
                size: 22,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.breakfast_dining,
              size: 100,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: Opacity(
            opacity: 0.15,
            child: Icon(
              Icons.dinner_dining,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 70,
          right: 100,
          child: Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.rice_bowl,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}