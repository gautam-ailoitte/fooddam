// lib/src/presentation/presentation_helpers/plan/plan_details_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';
import 'package:foodam/src/presentation/views/payment_page.dart';

/// Helper class for PlanDetailsPage UI logic
class PlanDetailsHelper {
  /// Build the plan summary card
  static Widget buildPlanSummaryCard(BuildContext context, Plan plan) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.isVeg ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plan.isVeg ? 'Veg' : 'Non-Veg',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDurationText(plan.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  PriceFormatter.formatPrice(plan.totalPrice),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get PaymentSummaryPage with plan
  static Widget getPaymentSummaryPage(Plan plan) {
    return PaymentSummaryPage(plan: plan);
  }
  
  /// Get the plan price breakdown for display
  static Map<String, double> getPriceBreakdown(Plan plan) {
    double basePrice = plan.basePrice;
    double customizationCharges = 0.0;
    
    // Calculate customization charges
    plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) {
        customizationCharges += dailyMeals.breakfast!.additionalPrice;
      }
      if (dailyMeals.lunch != null) {
        customizationCharges += dailyMeals.lunch!.additionalPrice;
      }
      if (dailyMeals.dinner != null) {
        customizationCharges += dailyMeals.dinner!.additionalPrice;
      }
    });
    
    // Calculate discount based on duration
    double discount = PriceFormatter.calculateDiscount(
      basePrice + customizationCharges,
      plan.duration
    );
    
    // Calculate total
    double total = basePrice + customizationCharges - discount;
    
    return {
      'basePrice': basePrice,
      'customizationCharges': customizationCharges,
      'discount': discount,
      'total': total
    };
  }
  
  /// Calculate the total meals in the plan
  static int calculateTotalMeals(Plan plan) {
    int count = 0;
    
    plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) count++;
      if (dailyMeals.lunch != null) count++;
      if (dailyMeals.dinner != null) count++;
    });
    
    return count;
  }
  
  /// Get plan duration as readable text
  static String _getDurationText(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
    }
  }
  
  /// Check if all meals are selected for the plan
  static bool isAllMealsSelected(Plan plan) {
    int requiredMeals = 0;
    
    // Calculate required meals based on duration
    switch (plan.duration) {
      case PlanDuration.sevenDays:
        requiredMeals = 7 * 3; // 7 days, 3 meals per day
        break;
      case PlanDuration.fourteenDays:
        requiredMeals = 14 * 3; // 14 days, 3 meals per day
        break;
      case PlanDuration.twentyEightDays:
        requiredMeals = 28 * 3; // 28 days, 3 meals per day
        break;
    }
    
    // Count selected meals
    int selectedMeals = calculateTotalMeals(plan);
    
    return selectedMeals == requiredMeals;
  }
  
  /// Get a warning message if the plan is incomplete
  static String? getMissingMealsWarning(Plan plan) {
    if (isAllMealsSelected(plan)) {
      return null;
    }
    
    int totalMeals = calculateTotalMeals(plan);
    int requiredMeals = 0;
    
    switch (plan.duration) {
      case PlanDuration.sevenDays:
        requiredMeals = 7 * 3;
        break;
      case PlanDuration.fourteenDays:
        requiredMeals = 14 * 3;
        break;
      case PlanDuration.twentyEightDays:
        requiredMeals = 28 * 3;
        break;
    }
    
    int missingMeals = requiredMeals - totalMeals;
    
    return 'Your plan is incomplete. You still need to select $missingMeals meal(s).';
  }
}