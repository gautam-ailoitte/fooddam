// lib/src/presentation/presentation_helpers/plan_selection_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';

/// Helper class for PlanSelectionPage UI logic
class PlanSelectionHelper {
  /// Filter plans by duration
  static List<Plan> filterPlansByDuration(List<Plan> plans, PlanDuration duration) {
    return plans.where((plan) => plan.duration == duration).toList();
  }
  
  /// Build draft plan banner
  static Widget buildDraftBanner(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber[700]!),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_document, color: Colors.amber[800]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have a draft plan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                  Text(
                    'Tap to resume customization',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber[800]),
          ],
        ),
      ),
    );
  }
  
  /// Format duration for display
  static String formatDuration(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
    }
  }
  
  /// Get discount percentage based on plan duration
  static double getDiscountPercentage(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return 0.0; // No discount
      case PlanDuration.fourteenDays:
        return 0.05; // 5% discount
      case PlanDuration.twentyEightDays:
        return 0.10; // 10% discount
    }
  }
  
  /// Calculate discounted price
  static double calculateDiscountedPrice(double originalPrice, PlanDuration duration) {
    final discountPercentage = getDiscountPercentage(duration);
    return originalPrice * (1 - discountPercentage);
  }
}