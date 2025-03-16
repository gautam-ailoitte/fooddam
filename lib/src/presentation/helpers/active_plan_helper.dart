// lib/src/presentation/presentation_helpers/plan/active_plan_helper.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/plan_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';
import 'package:foodam/src/presentation/helpers/thali_selection_helper.dart';
import 'package:foodam/src/presentation/utlis/date_formatter_utility.dart';
import 'package:foodam/src/presentation/utlis/price_formatter_utility.dart';

/// Helper class for ActivePlanPage UI logic
class ActivePlanHelper {
  /// Build plan summary card
  static Widget buildPlanSummaryCard(BuildContext context, Plan plan) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Plan icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    plan.isVeg ? 'Vegetarian Plan' : 'Non-Vegetarian Plan',
                    style: TextStyle(
                      fontSize: 14,
                      color: plan.isVeg ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        _getPlanDateRangeText(plan),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build meal card for a specific meal type
  static Widget buildMealCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Thali? thali,
    required String time,
  }) {
    if (thali == null) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'No meal selected',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ThaliSelectionHelper.getThaliColor(thali.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: ThaliSelectionHelper.getThaliColor(thali.type),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ThaliSelectionHelper.getThaliColor(thali.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              thali.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: ThaliSelectionHelper.getThaliColor(thali.type),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Divider
            Divider(height: 24),
            
            // Meal items
            Text(
              'Meal Items:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: thali.selectedMeals.length,
              itemBuilder: (context, index) {
                final meal = thali.selectedMeals[index];
                return Row(
                  children: [
                    Icon(
                      ThaliSelectionHelper.getMealIcon(meal),
                      size: 14,
                      color: ThaliSelectionHelper.getMealIconColor(meal),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Thali price
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Price: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  PriceFormatter.formatPrice(thali.totalPrice),
                  style: TextStyle(
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
  
  /// Get plan date range as text
  static String _getPlanDateRangeText(Plan plan) {
    String startDateStr = DateFormatter.formatDate(plan.startDate);
    String endDateStr = DateFormatter.formatDate(plan.endDate);
    
    if (plan.startDate != null && plan.endDate != null) {
      return '$startDateStr to $endDateStr';
    } else if (plan.startDate != null) {
      return 'From $startDateStr';
    } else if (plan.endDate != null) {
      return 'Until $endDateStr';
    }
    
    return 'No dates set';
  }
  
  /// Check if a day is today
  static bool isToday(DayOfWeek day) {
    final today = DateTime.now().weekday - 1; // Convert to 0-based index
    final dayIndex = DayOfWeek.values.indexOf(day);
    return today == dayIndex;
  }
  
  /// Get days remaining in the plan
  static int getDaysRemaining(Plan plan) {
    if (plan.endDate == null) return 0;
    
    final now = DateTime.now();
    final end = plan.endDate!;
    
    if (end.isBefore(now)) return 0;
    
    return end.difference(now).inDays + 1; // +1 to include the end day
  }
  
  /// Format the remaining days message
  static String getRemainingDaysMessage(Plan plan) {
    final daysRemaining = getDaysRemaining(plan);
    
    if (daysRemaining <= 0) {
      return 'Plan has expired';
    } else if (daysRemaining == 1) {
      return 'Last day of plan';
    } else {
      return '$daysRemaining days remaining';
    }
  }
}