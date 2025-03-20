// lib/src/presentation/widgets/plan_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/subscription_plan_entity.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback? onTap;
  final bool isSelected;
  
  const PlanCard({
    super.key,
    required this.plan,
    this.onTap,
    this.isSelected = false,
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
          // Header section
          _buildHeader(context),
          
          Divider(color: AppColors.divider),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              plan.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          
          // Plan features
          _buildPlanFeatures(context),
          
          // Footer with pricing and button
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Plan icon/badge
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getPlanColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPlanIcon(),
            color: _getPlanColor(),
            size: 28,
          ),
        ),
        AppSpacing.hMd,
        // Plan title and type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getPlanType(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getPlanColor(),
                ),
              ),
            ],
          ),
        ),
        // Customizable badge
        if (_isPlanCustomizable()) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  StringConstants.customizable,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanFeatures(BuildContext context) {
    // Get sample of meal templates to show as features
    final sampleMeals = _getSampleMeals();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.includes,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        for (var meal in sampleMeals) ...[
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meal,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        
        // Meal frequency
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.dailyBreakfastLunchDinner,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${plan.price.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              StringConstants.startingAt,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        AppSpacing.hMd,
        // Select button
        Expanded(
          child: AppButton(
            label: StringConstants.selectPlan,
            onPressed: onTap,
            buttonType: isSelected ? AppButtonType.primary : AppButtonType.outline,
            buttonSize: AppButtonSize.medium,
            isFullWidth: true,
          ),
        ),
      ],
    );
  }

  // Helper methods
  IconData _getPlanIcon() {
    if (plan.name.toLowerCase().contains('vegetarian') || 
        plan.name.toLowerCase().contains('veg')) {
      return Icons.eco;
    } else if (plan.name.toLowerCase().contains('non-veg')) {
      return Icons.restaurant;
    } else if (plan.name.toLowerCase().contains('premium') || 
               plan.name.toLowerCase().contains('deluxe')) {
      return Icons.star;
    } else if (plan.name.toLowerCase().contains('healthy') || 
               plan.name.toLowerCase().contains('lite')) {
      return Icons.fitness_center;
    }
    return Icons.restaurant_menu;
  }

  Color _getPlanColor() {
    if (plan.name.toLowerCase().contains('vegetarian') || 
        plan.name.toLowerCase().contains('veg')) {
      return AppColors.vegetarian;
    } else if (plan.name.toLowerCase().contains('non-veg')) {
      return AppColors.nonVegetarian;
    } else if (plan.name.toLowerCase().contains('premium') || 
               plan.name.toLowerCase().contains('deluxe')) {
      return AppColors.accent;
    } else if (plan.name.toLowerCase().contains('healthy') || 
               plan.name.toLowerCase().contains('lite')) {
      return AppColors.info;
    }
    return AppColors.primary;
  }

  String _getPlanType() {
    if (plan.name.toLowerCase().contains('vegetarian') || 
        plan.name.toLowerCase().contains('veg')) {
      return StringConstants.vegetarian;
    } else if (plan.name.toLowerCase().contains('non-veg')) {
      return StringConstants.nonVegetarian;
    }
    return '';
  }

  bool _isPlanCustomizable() {
    // This would be determined by plan data
    // For now, we'll assume all plans are customizable
    return true;
  }

  List<String> _getSampleMeals() {
    final samples = <String>[];
    final uniqueMeals = <String>{};
    
    // Collect unique meals from the template (limit to 3)
    for (var mealTemplate in plan.weeklyMealTemplate) {
      if (uniqueMeals.length < 3 && !uniqueMeals.contains(mealTemplate.meal)) {
        uniqueMeals.add(mealTemplate.meal);
        samples.add(mealTemplate.meal);
      }
    }
    
    return samples;
  }
}