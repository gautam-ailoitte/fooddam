// lib/features/meal_selection/widgets/day_tab.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';
class DayTab extends StatelessWidget {
  final String day;
  
  const DayTab({
    super.key,
    required this.day,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.marginMedium,
          vertical: AppDimensions.marginSmall,
        ),
        child: Text(
          day,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



class MealTypeHeader extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool> onToggle;
  
  const MealTypeHeader({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onToggle,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _getIconForMealType(title),
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(width: AppDimensions.marginSmall),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Switch(
          value: isSelected,
          onChanged: onToggle,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
  
  IconData _getIconForMealType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}


class MealSelectionCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  
  const MealSelectionCard({
    super.key,
    required this.meal,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isVegetarian = meal.dietaryPreferences?.contains('vegetarian') ?? false;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal header
              Row(
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
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.vegetarian.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      size: 12,
                                      color: AppColors.vegetarian,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Veg',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.vegetarian,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppDimensions.marginMedium),
              Divider(),
              SizedBox(height: AppDimensions.marginSmall),
              
              // Dishes included
              Text(
                'Includes:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: AppDimensions.marginSmall),
              
              // Dish list
              ...meal.dishes.map((dish) => _buildDishItem(context, dish.name, dish.category)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDishItem(BuildContext context, String name, String category) {
    IconData icon;
    switch (category.toLowerCase()) {
      case 'main_course':
        icon = Icons.restaurant;
        break;
      case 'side_dish':
        icon = Icons.rice_bowl;
        break;
      case 'beverage':
        icon = Icons.local_drink;
        break;
      case 'dessert':
        icon = Icons.icecream;
        break;
      case 'appetizer':
        icon = Icons.tapas;
        break;
      case 'soup':
        icon = Icons.soup_kitchen;
        break;
      default:
        icon = Icons.food_bank;
    }
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            _formatCategory(category),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  String _formatCategory(String category) {
    final words = category.split('_');
    return words.map((word) => 
      word.isNotEmpty 
          ? '${word[0].toUpperCase()}${word.substring(1)}' 
          : ''
    ).join(' ');
  }
}