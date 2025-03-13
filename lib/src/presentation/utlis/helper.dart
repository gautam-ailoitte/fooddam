// Navigation helper
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

class NavigationHelper {
  static void goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  static void goToPayment(BuildContext context) {
    Navigator.of(context).pushNamed('/payment');
  }
  
  static void goToPlanDetails(BuildContext context) {
    Navigator.of(context).pushNamed('/plan-details');
  }
  
  static void goToPlanSelection(BuildContext context) {
    Navigator.of(context).pushNamed('/plan-selection');
  }
  
  static void goToThaliSelection(
    BuildContext context, 
    DayOfWeek day,
    MealType mealType
  ) {
    Navigator.of(context).pushNamed(
      '/thali-selection',
      arguments: {
        'dayOfWeek': day,
        'mealType': mealType,
      },
    );
  }
  
  static void goToMealCustomization(
    BuildContext context,
    Thali thali,
    DayOfWeek day,
    MealType mealType
  ) {
    Navigator.of(context).pushNamed(
      '/meal-customization',
      arguments: {
        'thali': thali,
        'dayOfWeek': day,
        'mealType': mealType,
      },
    );
  }
}

// Extension for Plan state management
extension PlanExtensions on Plan {
  // Check if plan has been modified from template
  bool get isModified {
    if (!isCustomized) return false;
    
    // Count non-null meals
    int mealCount = 0;
    mealsByDay.forEach((day, meals) {
      if (meals.breakfast != null) mealCount++;
      if (meals.lunch != null) mealCount++;
      if (meals.dinner != null) mealCount++;
    });
    
    return mealCount > 0;
  }
  
  // Get short description
  String get shortDescription {
    return '$name (${isVeg ? 'Veg' : 'Non-Veg'}) - ${durationText}';
  }
  
  // Get duration text
  String get durationText {
    switch (duration) {
      case PlanDuration.sevenDays:
        return '7 Days';
      case PlanDuration.fourteenDays:
        return '14 Days';
      case PlanDuration.twentyEightDays:
        return '28 Days';
      }
  }
}

// Dialog helpers
class DialogHelper {
  static Future<bool?> showDiscardConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Changes?'),
        content: Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Discard'),
          ),
        ],
      ),
    );
  }
  
  static Future<String?> showDraftActionDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Draft Plan Found'),
        content: Text('You have a saved draft plan. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('new'),
            child: Text('Start New Plan'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('resume'),
            child: Text('Resume Draft'),
          ),
        ],
      ),
    );
  }
  
  static void showPaymentSuccess(BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Your meal plan has been activated successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onComplete();
            },
            child: Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}