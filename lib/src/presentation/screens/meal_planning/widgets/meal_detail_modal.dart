// lib/src/presentation/widgets/meal_planning/meal_detail_modal.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/domain/entities/meal_planning/calculated_plan_entity.dart';

class MealDetailModal extends StatelessWidget {
  final MealDish dish;
  final String dayName;
  final String mealType;
  final bool isSelected;
  final VoidCallback onSelectionChanged;

  const MealDetailModal({
    super.key,
    required this.dish,
    required this.dayName,
    required this.mealType,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMealImage(context),
                      SizedBox(height: AppSpacing.lg),
                      _buildMealInfo(context),
                      SizedBox(height: AppSpacing.md),
                      _buildDescription(context),
                      SizedBox(height: AppSpacing.md),
                      _buildMealDetails(context),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.borderRadiusMd),
          topRight: Radius.circular(AppDimensions.borderRadiusMd),
        ),
      ),
      child: Row(
        children: [
          Icon(_getMealTypeIcon(), color: AppColors.primary, size: 24),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMealType(mealType),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDayName(dayName),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMealImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
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
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getMealTypeIcon(), color: Colors.grey.shade400, size: 48),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No Image Available',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                dish.name ?? 'Unknown Meal',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (dish.price != null && dish.price! > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '₹${dish.price}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildDietaryBadge(context),
            SizedBox(width: AppSpacing.sm),
            _buildAvailabilityBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryBadge(BuildContext context) {
    final isVeg = dish.dietaryPreference?.toLowerCase() == 'vegetarian';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVeg ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVeg ? Colors.green : Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isVeg ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            isVeg ? 'Vegetarian' : 'Non-Vegetarian',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isVeg ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context) {
    final available = dish.isAvailable ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: available ? Colors.green.shade300 : Colors.orange.shade300,
          width: 1,
        ),
      ),
      child: Text(
        available ? 'Available' : 'Limited',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: available ? Colors.green.shade700 : Colors.orange.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (dish.description == null || dish.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          dish.description!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMealDetails(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meal Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Meal Time: ${_formatMealType(mealType)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Day: ${_formatDayName(dayName)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          if (dish.key != null) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.tag, size: 16, color: AppColors.textSecondary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Slot: ${dish.key}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.borderRadiusMd),
          bottomRight: Radius.circular(AppDimensions.borderRadiusMd),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              text: isSelected ? 'Remove from Plan' : 'Add to Plan',
              onPressed: () {
                onSelectionChanged();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon() {
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

  String _formatMealType(String mealType) {
    return mealType.substring(0, 1).toUpperCase() + mealType.substring(1);
  }

  String _formatDayName(String dayName) {
    return dayName.substring(0, 1).toUpperCase() + dayName.substring(1);
  }
}
