// lib/features/auth/widgets/foodam_logo.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';

class FoodamLogo extends StatelessWidget {
  final double size;
  
  const FoodamLogo({
    super.key,
    required this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: size * 0.6,
          color: AppColors.primary,
        ),
      ),
    );
  }
}