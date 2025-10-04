// lib/src/presentation/screens/meal_planning/widgets/meal_card_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';

import '../../../../domain/entities/meal_planning/calculated_plan_entity.dart';
import 'meal_detail_modal.dart';

class MealCardWidget extends StatelessWidget {
  final MealDish dish;
  final String slotKey;
  final String dayName;
  final String mealType;
  final bool isSelected;
  final VoidCallback onSelectionChanged;

  const MealCardWidget({
    super.key,
    required this.dish,
    required this.slotKey,
    required this.dayName,
    required this.mealType,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectionChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal image (larger for 3-column)
                _buildMealImage(context),

                // Meal name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Dietary & price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (dish.dietaryPreference != null)
                            _buildDietaryBadge(),

                          if (dish.price != null && dish.price! > 0)
                            _buildPriceTag(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Selection checkbox
            Positioned(top: 4, right: 4, child: _buildSelectionCheckbox()),

            // Info button
            Positioned(top: 4, left: 4, child: _buildInfoButton(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealImage(BuildContext context) {
    return Container(
      height: 60, // Larger image for 3-column layout
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(7),
          topRight: Radius.circular(7),
        ),
        child:
            dish.image?.url != null
                ? Image.network(
                  dish.image!.url!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          _buildImagePlaceholder(context),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildImagePlaceholder(context);
                  },
                )
                : _buildImagePlaceholder(context),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    IconData mealIcon;
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        mealIcon = Icons.free_breakfast;
        break;
      case 'lunch':
        mealIcon = Icons.lunch_dining;
        break;
      case 'dinner':
        mealIcon = Icons.dinner_dining;
        break;
      default:
        mealIcon = Icons.restaurant;
    }

    return Center(child: Icon(mealIcon, color: Colors.grey.shade400, size: 28));
  }

  Widget _buildSelectionCheckbox() {
    return GestureDetector(
      onTap: onSelectionChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child:
            isSelected
                ? Icon(Icons.check, color: Colors.white, size: 16)
                : null,
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMealDetails(context),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(Icons.info_outline, color: Colors.white, size: 14),
      ),
    );
  }

  Widget _buildDietaryBadge() {
    final isVeg = dish.dietaryPreference?.toLowerCase() == 'vegetarian';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isVeg ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2),
          Text(
            isVeg ? 'V' : 'NV',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '₹${dish.price}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showMealDetails(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => MealDetailModal(
            dish: dish,
            dayName: dayName,
            mealType: mealType,
            isSelected: isSelected,
            onSelectionChanged: onSelectionChanged,
          ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return AppColors.primary.withOpacity(0.1);
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isSelected) {
      return AppColors.primary;
    }
    return Colors.grey.shade300;
  }
}
