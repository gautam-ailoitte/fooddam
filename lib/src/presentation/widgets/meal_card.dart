// lib/src/presentation/widgets/meal_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/meal_entity.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onCustomize;
  
  const MealCard({
    super.key,
    required this.meal,
    this.isSelected = false,
    this.onSelect,
    this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      backgroundColor: isSelected ? AppColors.primaryLight.withOpacity(0.2) : null,
      border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with meal name and dietary info
          _buildHeader(context),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              meal.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          
          // Dishes included
          _buildDishesSection(context),
          
          // Divider
          Divider(color: AppColors.divider),
          
          // Footer with price and actions
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Meal image or icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getDietaryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMealIcon(),
            color: _getDietaryColor(),
            size: 36,
          ),
        ),
        AppSpacing.hMd,
        // Meal title and dietary info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: _buildDietaryBadges(context),
              ),
            ],
          ),
        ),
        if (isSelected) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDishesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.mealItems,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Display up to 3 dishes with the option to "show more"
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildDishItems(context),
        ),
      ],
    );
  }

  List<Widget> _buildDishItems(BuildContext context) {
    const int maxVisibleItems = 3;
    final items = <Widget>[];
    
    for (int i = 0; i < meal.dishes.length; i++) {
      if (i < maxVisibleItems) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.dishes[i].name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        meal.dishes[i].description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
    
    // Add "show more" button if there are more items
    if (meal.dishes.length > maxVisibleItems) {
      items.add(
        TextButton(
          onPressed: () {
            // Show dialog with all dishes
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'All Dishes in ${meal.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: meal.dishes.map((dish) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    dish.name,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${dish.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dish.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dish.category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'Show all ${meal.dishes.length} dishes',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${StringConstants.price} ₹${meal.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (meal.isAvailable == true) ...[
              Text(
                'Available now',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        // Customize button (optional)
        if (onCustomize != null) ...[
          AppButton(
            label: StringConstants.customize,
            onPressed: onCustomize,
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.small,
            leadingIcon: Icons.edit_outlined,
          ),
          AppSpacing.hSm,
        ],
        // Select button
        AppButton(
          label: StringConstants.select,
          onPressed: onSelect,
          buttonType: isSelected ? AppButtonType.primary : AppButtonType.outline,
          buttonSize: AppButtonSize.small,
        ),
      ],
    );
  }

  List<Widget> _buildDietaryBadges(BuildContext context) {
    final List<Widget> badges = [];
    
    if (meal.dietaryPreferences == null || meal.dietaryPreferences!.isEmpty) {
      return badges;
    }
    
    for (final preference in meal.dietaryPreferences!) {
      final color = _getDietaryColorByPreference(preference);
      
      badges.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            preference,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }
    
    return badges;
  }

  IconData _getMealIcon() {
    if (meal.dietaryPreferences != null) {
      if (meal.dietaryPreferences!.contains('vegetarian')) {
        return Icons.eco;
      } else if (meal.dietaryPreferences!.contains('non-vegetarian')) {
        return Icons.restaurant;
      }
    }
    
    // Default icon based on meal name
    if (meal.name.toLowerCase().contains('breakfast')) {
      return Icons.breakfast_dining;
    } else if (meal.name.toLowerCase().contains('lunch')) {
      return Icons.lunch_dining;
    } else if (meal.name.toLowerCase().contains('dinner')) {
      return Icons.dinner_dining;
    }
    
    return Icons.restaurant_menu;
  }

  Color _getDietaryColor() {
    if (meal.dietaryPreferences != null) {
      if (meal.dietaryPreferences!.contains('vegetarian')) {
        return AppColors.vegetarian;
      } else if (meal.dietaryPreferences!.contains('non-vegetarian')) {
        return AppColors.nonVegetarian;
      }
    }
    
    return AppColors.primary;
  }

  Color _getDietaryColorByPreference(String preference) {
    switch (preference.toLowerCase()) {
      case 'vegetarian':
        return AppColors.vegetarian;
      case 'vegan':
        return AppColors.vegan;
      case 'non-vegetarian':
        return AppColors.nonVegetarian;
      case 'gluten-free':
        return AppColors.glutenFree;
      case 'dairy-free':
        return AppColors.dairyFree;
      default:
        return AppColors.textSecondary;
    }
  }
}