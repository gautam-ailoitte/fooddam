// lib/src/presentation/presentation_helpers/plan/payment_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';

/// Helper class for Payment related UI logic
class PaymentHelper {
  /// Build info row with label and value
  static Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build price row with label and amount
  static Widget buildPriceRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            PriceFormatter.formatPrice(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build day price row
  static Widget buildDayPriceRow(String day, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day),
          Text(PriceFormatter.formatPrice(amount)),
        ],
      ),
    );
  }
  
  /// Build discount row
  static Widget buildDiscountRow(BuildContext context, PlanDuration duration, Plan plan) {
    final baseAmount = plan.basePrice + calculateCustomizationCharges(plan);
    final discountAmount = PriceFormatter.calculateDiscount(baseAmount, duration);
    
    if (discountAmount <= 0) {
      return SizedBox.shrink(); // No discount
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discount (${PriceFormatter.getDiscountPercentage(duration)})',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          Text(
            '-${PriceFormatter.formatPrice(discountAmount)}',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Calculate total customization charges
  static double calculateCustomizationCharges(Plan plan) {
    double total = 0.0;
    
    plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) {
        total += dailyMeals.breakfast!.additionalPrice;
      }
      if (dailyMeals.lunch != null) {
        total += dailyMeals.lunch!.additionalPrice;
      }
      if (dailyMeals.dinner != null) {
        total += dailyMeals.dinner!.additionalPrice;
      }
    });
    
    return total;
  }
  
  /// Calculate total number of meals in the plan
  static int calculateTotalMeals(Plan plan) {
    int totalMeals = 0;
    
    plan.mealsByDay.forEach((day, dailyMeals) {
      if (dailyMeals.breakfast != null) totalMeals++;
      if (dailyMeals.lunch != null) totalMeals++;
      if (dailyMeals.dinner != null) totalMeals++;
    });
    
    return totalMeals;
  }
  
  /// Get duration as text
  static String getDurationText(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
    }
  }
  
  /// Calculate end date based on start date and duration
  static DateTime calculateEndDate(DateTime startDate, PlanDuration duration) {
    int days;
    
    switch (duration) {
      case PlanDuration.sevenDays:
        days = 7;
        break;
      case PlanDuration.fourteenDays:
        days = 14;
        break;
      case PlanDuration.twentyEightDays:
        days = 28;
        break;
    }
    
    return startDate.add(Duration(days: days - 1));
  }
  
  /// Generate a mock transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TXN_$timestamp';
  }
}