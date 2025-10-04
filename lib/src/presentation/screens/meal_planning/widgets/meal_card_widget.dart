// lib/src/presentation/widgets/meal_planning/meal_card_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';ng/calculated_plan_entity.dart';

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
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSm),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
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
            Padding(
              padding: EdgeInsets.all(AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal image
                  _buildMealImage(context),
                  SizedBox(height: AppSpacing.xs),

                  // Meal name
                  Expanded(
                    child: Text(
                      dish.name ?? 'Unknown Meal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Dietary preference indicator
                  if (dish.dietaryPreference != null)
                    _buildDietaryIndicator(context),
                ],
              ),
            ),

            // Selection checkbox
            Positioned(
              top: 4,
              right: 4,
              child: _buildSelectionCheckbox(context),
            ),

            // Info button
            Positioned(
              top: 4,
              left: 4,
              child: _buildInfoButton(context),
            ),

            // Price overlay (if applicable)
            if (dish.price != null && dish.price! > 0)
              Positioned(
                bottom: 4,
                right: 4,
                child: _buildPriceTag(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealImage(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: dish.image?.url != null
            ? Image.network(
          dish.image!.url!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(context),
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

    return Center(
      child: Icon(
        mealIcon,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }

  Widget _buildSelectionCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: onSelectionChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: isSelected
            ? Icon(
          Icons.check,
          color: Colors.white,
          size: 14,
        )
            : null,
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMealDetails(context),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.info_outline,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  Widget _buildDietaryIndicator(BuildContext context) {
    final isVeg = dish.dietaryPreference?.toLowerCase() == 'vegetarian';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isVeg ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2),
          Text(
            isVeg ? 'V' : 'NV',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showMealDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MealDetailModal(
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