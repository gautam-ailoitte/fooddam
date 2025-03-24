// lib/features/home/widgets/today_meals_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';

class TodayMealsWidget extends StatelessWidget {
  final Map<String, List<MealOrder>> mealsByType;
  final String currentMealPeriod;
  
  const TodayMealsWidget({
    super.key,
    required this.mealsByType,
    required this.currentMealPeriod,
  });
  
  @override
  Widget build(BuildContext context) {
    // Get meal types that have meals
    final mealTypes = mealsByType.keys.where((type) => mealsByType[type]!.isNotEmpty).toList();
    
    return Column(
      children: [
        // First show current meal period
        if (mealsByType[currentMealPeriod]?.isNotEmpty ?? false) ...[
          _buildMealSection(context, currentMealPeriod, mealsByType[currentMealPeriod]!, true),
        ],
        
        // Then show other meal periods
        ...mealTypes
            .where((type) => type != currentMealPeriod)
            .map((type) => _buildMealSection(context, type, mealsByType[type]!, false)),
      ],
    );
  }
  
  Widget _buildMealSection(
    BuildContext context,
    String mealType,
    List<MealOrder> meals,
    bool isCurrent,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        right: AppDimensions.marginMedium,
        bottom: AppDimensions.marginMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mealType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrent) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                  ),
                  child: Text(
                    'Current',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ...meals.map((meal) => _buildMealItem(context, meal)),
        ],
      ),
    );
  }
  
  Widget _buildMealItem(BuildContext context, MealOrder meal) {
    final isUpcoming = meal.status == OrderStatus.coming;
    final iconData = isUpcoming ? Icons.access_time : Icons.check_circle;
    final iconColor = isUpcoming ? AppColors.warning : AppColors.success;
    final statusText = isUpcoming
        ? 'Coming soon - Expected at ${_formatTime(meal.expectedTime)}'
        : 'Delivered at ${_formatTime(meal.deliveredAt!)}';
    
    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.mealName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        iconData,
                        size: 16,
                        color: iconColor,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          statusText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: iconColor,
                          ),
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
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}