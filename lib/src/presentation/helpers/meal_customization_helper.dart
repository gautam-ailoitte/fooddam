// lib/src/presentation/presentation_helpers/meal/meal_customization_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/presentation/cubits/meal_customization_cubit/meal_customization_cubit.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';
import 'package:foodam/src/presentation/widgets/common/app_button.dart';

/// Helper class for MealCustomizationPage UI logic
class MealCustomizationHelper {
  /// Build the bottom bar for the meal customization page
  static Widget buildBottomBar(
    BuildContext context, 
    MealCustomizationActive state,
    VoidCallback onSave,
  ) {
    // Disable save button when there are no changes
    final hasChanges = state.hasChanges;
    
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    PriceFormatter.formatPrice(state.totalPrice),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppButton(
                label: hasChanges ? 'Save Changes' : 'Done',
                onPressed: onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get a list of meals that are part of a thali's current selection
  static List<Meal> getCurrentSelectionForDisplay(MealCustomizationActive state) {
    return state.currentSelection;
  }
  
  /// Check if adding another meal would exceed the maximum
  static bool canAddMoreMeals(MealCustomizationActive state) {
    return state.currentSelection.length < state.originalThali.maxCustomizations;
  }
  
  /// Calculate the price change from original to current selection
  static double calculatePriceChange(MealCustomizationActive state) {
    return state.totalPrice - state.originalThali.totalPrice;
  }
  
  /// Format the price change with + or - sign
  static String formatPriceChange(double priceChange) {
    if (priceChange > 0) {
      return '+${PriceFormatter.formatPrice(priceChange)}';
    } else if (priceChange < 0) {
      return '-${PriceFormatter.formatPrice(priceChange.abs())}';
    } else {
      return PriceFormatter.formatPrice(0);
    }
  }
  
  /// Get a user-friendly message based on selection status
  static String getSelectionStatusMessage(MealCustomizationActive state) {
    final maxMeals = state.originalThali.maxCustomizations;
    final currentCount = state.currentSelection.length;
    
    if (currentCount == 0) {
      return 'Please select at least one item';
    } else if (currentCount == maxMeals) {
      return 'Maximum selection reached';
    } else {
      return 'You can select ${maxMeals - currentCount} more items';
    }
  }
  
  /// Get the color for the selection status message
  static Color getSelectionStatusColor(MealCustomizationActive state) {
    final maxMeals = state.originalThali.maxCustomizations;
    final currentCount = state.currentSelection.length;
    
    if (currentCount == 0) {
      return Colors.red;
    } else if (currentCount == maxMeals) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}