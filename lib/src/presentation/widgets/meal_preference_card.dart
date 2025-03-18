// lib/src/presentation/widgets/subscription/meal_preference_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';

class MealPreferenceCard extends StatelessWidget {
  final String title;
  final List<DietaryPreference> dietaryPreferences;
  final int quantity;
  final VoidCallback onCustomize;

  const MealPreferenceCard({
    Key? key,
    required this.title,
    required this.dietaryPreferences,
    required this.quantity,
    required this.onCustomize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'Qty: $quantity',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: dietaryPreferences.map((pref) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getDietaryPreferenceColor(pref).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pref.toString().split('.').last,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getDietaryPreferenceColor(pref),
                      ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onCustomize,
            icon: const Icon(Icons.edit, size: 16),
            label: Text(StringConstants.customize),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDietaryPreferenceColor(DietaryPreference preference) {
    switch (preference) {
      case DietaryPreference.vegetarian:
        return AppColors.vegetarian;
      case DietaryPreference.nonVegetarian:
        return AppColors.nonVegetarian;
      case DietaryPreference.vegan:
        return Colors.green.shade700;
      case DietaryPreference.glutenFree:
        return Colors.orange;
      case DietaryPreference.dairyFree:
        return Colors.blue;
      case DietaryPreference.nutFree:
        return Colors.brown;
      case DietaryPreference.pescatarian:
        return Colors.cyan;
      case DietaryPreference.keto:
        return Colors.purple;
      case DietaryPreference.paleo:
        return Colors.amber.shade700;
      default:
        return AppColors.textSecondary;
    }
  }
}