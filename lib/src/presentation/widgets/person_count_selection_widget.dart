// lib/features/packages/widgets/person_count_selector.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class PersonCountSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  const PersonCountSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildButton(
          context,
          icon: Icons.remove,
          onPressed: value > minValue
              ? () => onChanged(value - 1)
              : null,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.marginMedium,
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.marginMedium,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Person${value > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _buildButton(
          context,
          icon: Icons.add,
          onPressed: value < maxValue
              ? () => onChanged(value + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null ? AppColors.primary : AppColors.background,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: onPressed != null ? Colors.white : Color(0xFFE0E0E0),
          ),
        ),
      ),
    );
  }
}



class MealPreviewCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealPreviewCard({
    super.key,
    required this.meal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isVegetarian = meal.dietaryPreferences?.contains('vegetarian') ?? false;

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image or placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: Center(
                  child: Icon(
                    isVegetarian ? Icons.eco : Icons.restaurant,
                    size: 40,
                    color: isVegetarian
                        ? AppColors.vegetarian
                        : AppColors.nonVegetarian,
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),
              
              // Meal details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (isVegetarian) ...[
                          Icon(
                            Icons.eco,
                            size: 16,
                            color: AppColors.vegetarian,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      meal.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    if (meal.dishes.isNotEmpty) ...[
                      Text(
                        'Includes: ${meal.dishes.map((dish) => dish.name).join(", ")}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}