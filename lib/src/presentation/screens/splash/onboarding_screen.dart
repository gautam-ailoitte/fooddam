// lib/src/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/storage_service.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/injection_container.dart' as di;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final StorageService _storageService = di.di<StorageService>();
  static const String _onboardingCompletedKey = 'ONBOARDING_COMPLETED';

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Daily Fresh Meals',
      description: 'Choose from a variety of delicious homemade meals updated daily',
      imagePath: 'assets/images/onboarding_daily_meals.png', // Placeholder, you'll need to add actual assets
      icon: Icons.restaurant_menu,
      backgroundColor: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Flexible Subscriptions',
      description: 'Customize your meal plan with flexible subscription options',
      imagePath: 'assets/images/onboarding_subscription.png',
      icon: Icons.calendar_today,
      backgroundColor: AppColors.accent,
    ),
    OnboardingPage(
      title: 'Contactless Delivery',
      description: 'Meals delivered right to your doorstep with our secure delivery service',
      imagePath: 'assets/images/onboarding_delivery.png',
      icon: Icons.delivery_dining,
      backgroundColor: AppColors.accent,
    ),
    OnboardingPage(
      title: 'Health & Nutrition',
      description: 'Nutritionally balanced meals prepared with high-quality ingredients',
      imagePath: 'assets/images/onboarding_health.png',
      icon: Icons.health_and_safety,
      backgroundColor: AppColors.accent,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    // Mark onboarding as completed
    await _storageService.setBool(_onboardingCompletedKey, true);
    
    if (!mounted) return;
    
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDotIndicator(index),
                ),
              ),
            ),
            
            // Only show Get Started button on the last page
            Padding(
              padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
              child: AppButton(
                      label: 'Get Started',
                      onPressed: _completeOnboarding,
                      buttonType: AppButtonType.primary,
                      buttonSize: AppButtonSize.large,
                      isFullWidth: true,
                    )
                  // : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image or Icon placeholder
          page.imagePath != null
              ? Image.asset(
                  page.imagePath!,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image not available
                    return _buildIconPlaceholder(page.icon, page.backgroundColor);
                  },
                )
              : _buildIconPlaceholder(page.icon, page.backgroundColor),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconPlaceholder(IconData icon, Color backgroundColor) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          size: 64,
          color: backgroundColor,
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppColors.accent 
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String? imagePath;
  final IconData icon;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    this.imagePath,
    required this.icon,
    required this.backgroundColor,
  });
}