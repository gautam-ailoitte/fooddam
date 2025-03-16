// Navigation helper
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';


class NavigationHelper {
  static void goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  static void goToPaymentSummary(BuildContext context, Plan plan) {
    Navigator.of(context).pushNamed(AppRoutes.paymentSummary, arguments: plan);
  }
  
  static void goToPlanDetails(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.planDetails);
  }
  
  static void goToPlanSelection(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.planSelection);
  }
  
  static void goToThaliSelection(
    BuildContext context, 
    DayOfWeek day,
    MealType mealType
  ) {
    Navigator.of(context).pushNamed(
      AppRoutes.thaliSelection,
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
      AppRoutes.mealCustomization,
      arguments: {
        'thali': thali,
        'dayOfWeek': day,
        'mealType': mealType,
      },
    );
  }
  
  static void goToActivePlan(BuildContext context, Plan plan) {
    Navigator.of(context).pushNamed(
      AppRoutes.activePlan,
      arguments: plan,
    );
  }
}// Extension for Plan state management
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
    return '$name (${isVeg ? 'Veg' : 'Non-Veg'}) - $durationText';
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
      builder:
          (context) => AlertDialog(
            title: Text(StringConstants.discardCustomizations),
            content: Text(StringConstants.discardCustomizationsMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(StringConstants.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(StringConstants.discard),
              ),
            ],
          ),
    );
  }

  static Future<String?> showDraftActionDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(StringConstants.draftPlanFound),
            content: Text(StringConstants.draftPlanFoundMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('new'),
                child: Text(StringConstants.startNewPlan),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('resume'),
                child: Text(StringConstants.resumeDraftPlan),
              ),
            ],
          ),
    );
  }

  static void showPaymentSuccess(
    BuildContext context,
    VoidCallback onComplete,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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
                    StringConstants.paymentSuccessful,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    StringConstants.paymentSuccessMessage,
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
                child: Text(StringConstants.goToHome),
              ),
            ],
          ),
    );
  }
}
