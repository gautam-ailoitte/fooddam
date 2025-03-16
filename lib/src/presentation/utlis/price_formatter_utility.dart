// lib/src/presentation/presentation_helpers/core/price_formatter.dart
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';

/// Price formatting utilities for the presentation layer
class PriceFormatter {
  static const String DEFAULT_CURRENCY = '₹';
  static const int DEFAULT_DECIMAL_PLACES = 2;
  
  /// Format price with currency symbol
  static String formatPrice(double price, {
    String currency = DEFAULT_CURRENCY,
    int decimalPlaces = DEFAULT_DECIMAL_PLACES,
  }) {
    return '$currency${price.toStringAsFixed(decimalPlaces)}';
  }
  
  /// Calculate discount for a plan
  static double calculateDiscount(double originalPrice, PlanDuration duration) {
    double discountRate;
    
    switch (duration) {
      case PlanDuration.sevenDays:
        discountRate = 0.0; // No discount
        break;
      case PlanDuration.fourteenDays:
        discountRate = 0.05; // 5% discount
        break;
      case PlanDuration.twentyEightDays:
        discountRate = 0.10; // 10% discount
        break;
    }
    
    return originalPrice * discountRate;
  }
  
  /// Calculate discounted price
  static double calculateDiscountedPrice(double originalPrice, PlanDuration duration) {
    final discount = calculateDiscount(originalPrice, duration);
    return originalPrice - discount;
  }
  
  /// Get discount rate as percentage string
  static String getDiscountPercentage(PlanDuration duration) {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '0%';
      case PlanDuration.fourteenDays:
        return '5%';
      case PlanDuration.twentyEightDays:
        return '10%';
    }
  }
  
  /// Format additional charge
  static String formatAdditionalCharge(double charge) {
    if (charge <= 0) return '+${formatPrice(0)}';
    return '+${formatPrice(charge)}';
  }
}