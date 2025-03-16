import 'package:flutter/material.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/domain/entities/daily_meals_entity.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/thali_entity.dart';

class MealSummary extends StatelessWidget {
  final DailyMeals dailyMeals;
  final Function(MealType) onMealEdit;

  const MealSummary({
    super.key,
    required this.dailyMeals,
    required this.onMealEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMealSection(
              context,
              mealType: MealType.breakfast,
              thali: dailyMeals.breakfast,
              title: StringConstants.breakfast,
            ),
            Divider(),
            _buildMealSection(
              context,
              mealType: MealType.lunch,
              thali: dailyMeals.lunch,
              title: StringConstants.lunch,
            ),
            Divider(),
            _buildMealSection(
              context,
              mealType: MealType.dinner,
              thali: dailyMeals.dinner,
              title: StringConstants.dinner,
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${dailyMeals.dailyTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  Widget _buildMealSection(
    BuildContext context, {
    required MealType mealType,
    required Thali? thali,
    required String title,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: () => onMealEdit(mealType),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          SizedBox(height: 8),
          if (thali != null) ...[
            Text(
              thali.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            ...thali.selectedMeals.map((meal) => Padding(
              padding: EdgeInsets.only(left: 8, top: 2, bottom: 2),
              child: Row(
                children: [
                  Icon(
                    meal.isVeg ? Icons.eco : Icons.restaurant,
                    size: 14,
                    color: meal.isVeg ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '₹${thali.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'No meal selected',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[500],
              ),
            ),
        ],
      ),
    );
  }
}