// lib/core/theme/enhanced_app_theme.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';

class EnhancedTheme {
  // Enhanced card decoration with better shadows and rounded corners
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.1),
          offset: Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Enhanced button styles with gradients
  static ButtonStyle get primaryButtonStyle {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.4),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  // Gradient background for headers
  static BoxDecoration get headerGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    );
  }

  // Enhanced container for sections
  static BoxDecoration get sectionDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withOpacity(0.05),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );
  }

  // Food-themed bullet point
  static Widget foodBulletPoint({Color color = AppColors.primary}) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.only(right: 8, top: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // Meal tag (veg, non-veg, etc.)
  static Widget mealTypeTag(String type, {Color? color}) {
    Color tagColor;
    IconData tagIcon;

    switch (type.toLowerCase()) {
      case 'vegetarian':
        tagColor = AppColors.vegetarian;
        tagIcon = Icons.eco;
        break;
      case 'non-vegetarian':
        tagColor = AppColors.nonVegetarian;
        tagIcon = Icons.restaurant;
        break;
      case 'vegan':
        tagColor = AppColors.vegan;
        tagIcon = Icons.spa;
        break;
      default:
        tagColor = color ?? AppColors.primary;
        tagIcon = Icons.local_dining;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tagColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tagIcon, size: 12, color: tagColor),
          SizedBox(width: 4),
          Text(
            type,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }
}