// lib/src/presentation/presentation_helpers/meal/thali_selection_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

/// Helper class for ThaliSelectionPage UI logic
class ThaliSelectionHelper {
  /// Get meal type title from MealType
  static String getMealTypeTitle(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return StringConstants.breakfast;
      case MealType.lunch:
        return StringConstants.lunch;
      case MealType.dinner:
        return StringConstants.dinner;
    }
  }
  
  /// Get thali type display name
  static String getThaliTypeName(ThaliType type) {
    switch (type) {
      case ThaliType.normal:
        return StringConstants.normalThali;
      case ThaliType.nonVeg:
        return StringConstants.nonVegThali;
      case ThaliType.deluxe:
        return StringConstants.deluxeThali;
    }
  }
  
  /// Get color for thali type
  static Color getThaliColor(ThaliType type) {
    switch (type) {
      case ThaliType.normal:
        return Colors.green;
      case ThaliType.nonVeg:
        return Colors.red;
      case ThaliType.deluxe:
        return Colors.purple;
    }
  }
  
  /// Format thali price with currency
  static String formatThaliPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }
  
  /// Get meal icon based on its type
  static IconData getMealIcon(Meal meal) {
    return meal.isVeg ? Icons.eco : Icons.restaurant;
  }
  
  /// Get meal icon color
  static Color getMealIconColor(Meal meal) {
    return meal.isVeg ? Colors.green : Colors.red;
  }
}