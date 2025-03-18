// lib/src/presentation/widgets/menu/dish_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onTap;

  const DishCard({
    super.key,
    required this.dish,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dish image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade300,
              child: Image.network(
                dish.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.restaurant,
                    size: 40,
                    color: Colors.grey,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Dish details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish name with dietary indicator
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dish.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildDietaryBadge(dish.dietaryPreferences),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Dish description
                Text(
                  dish.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Price and quantity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${dish.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${dish.quantity.value} ${_formatUnit(dish.quantity.unit)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryBadge(List<DietaryPreference> preferences) {
    // Simplified - just showing veg/non-veg
    final isVeg = preferences.contains(DietaryPreference.vegetarian);
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isVeg ? AppColors.vegetarian : AppColors.nonVegetarian,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isVeg ? AppColors.vegetarian : AppColors.nonVegetarian,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  String _formatUnit(QuantityUnit unit) {
    switch (unit) {
      case QuantityUnit.grams:
        return 'g';
      case QuantityUnit.milliliters:
        return 'ml';
      case QuantityUnit.pieces:
        return 'pcs';
      case QuantityUnit.servings:
        return 'servings';
      case QuantityUnit.tablespoons:
        return 'tbsp';
      case QuantityUnit.teaspoons:
        return 'tsp';
      case QuantityUnit.cups:
        return 'cups';
      case QuantityUnit.ounces:
        return 'oz';
      case QuantityUnit.pounds:
        return 'lbs';
      default:
        return unit.toString().split('.').last;
    }
  }
}