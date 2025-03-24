// lib/features/home/widgets/welcome_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class WelcomeWidget extends StatelessWidget {
  final User user;
  
  const WelcomeWidget({
    super.key,
    required this.user,
  });
  
  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final displayName = user.firstName ?? 'there';
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $displayName!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Welcome to Foodam, your personalized meal subscription service.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}