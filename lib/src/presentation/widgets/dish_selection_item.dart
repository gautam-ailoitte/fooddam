// lib/src/presentation/widgets/meals/dish_selection_item.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class DishSelectionItem extends StatelessWidget {
  final Dish dish;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onRemove;
  final bool showQuantity;
  final int quantity;
  final bool isAdditionalItem;

  const DishSelectionItem({
    Key? key,
    required this.dish,
    required this.isSelected,
    required this.onSelect,
    required this.onRemove,
    this.showQuantity = false,
    this.quantity = 1,
    this.isAdditionalItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isSelected ? onRemove : onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Dish image or icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: dish.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          dish.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant,
                              color: AppColors.textSecondary,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
              ),
              const SizedBox(width: 12),
              
              // Dish details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (isAdditionalItem) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '+₹${dish.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Dietary preferences
                        ...dish.dietaryPreferences.map((pref) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: pref == DietaryPreference.vegetarian
                                  ? AppColors.vegetarian.withOpacity(0.1)
                                  : AppColors.nonVegetarian.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pref.toString().split('.').last,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: pref == DietaryPreference.vegetarian
                                        ? AppColors.vegetarian
                                        : AppColors.nonVegetarian,
                                  ),
                            ),
                          );
                        }),
                        
                        if (showQuantity) ...[
                          const Spacer(),
                          Text(
                            'Qty: $quantity',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.add,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}