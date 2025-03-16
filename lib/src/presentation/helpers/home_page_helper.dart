// lib/src/presentation/presentation_helpers/home_page_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

/// Helper class for HomePage UI logic
class HomePageHelper {
  /// Format date for display
  static String formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Get today's meal name by type
  static String getTodayMealName(Plan plan, MealType mealType) {
    final thali = getTodayMeal(plan, mealType);
    return thali?.name ?? 'Not selected';
  }
  
  /// Get today's meal by type
  static Thali? getTodayMeal(Plan plan, MealType mealType) {
    // Get today's day of week
    final today = DateTime.now().weekday;
    DayOfWeek dayOfWeek;

    switch (today) {
      case 1:
        dayOfWeek = DayOfWeek.monday;
        break;
      case 2:
        dayOfWeek = DayOfWeek.tuesday;
        break;
      case 3:
        dayOfWeek = DayOfWeek.wednesday;
        break;
      case 4:
        dayOfWeek = DayOfWeek.thursday;
        break;
      case 5:
        dayOfWeek = DayOfWeek.friday;
        break;
      case 6:
        dayOfWeek = DayOfWeek.saturday;
        break;
      case 7:
        dayOfWeek = DayOfWeek.sunday;
        break;
      default:
        dayOfWeek = DayOfWeek.monday;
    }

    // Use the helper method from our enhanced Plan model
    return plan.getMeal(dayOfWeek, mealType);
  }
  
  /// Build today's meal card widget
  static Widget buildTodayMealCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String thaliName,
    required String time,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(thaliName, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}