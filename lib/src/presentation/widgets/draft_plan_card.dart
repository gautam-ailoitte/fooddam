// lib/src/presentation/widgets/home/draft_plan_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class DraftPlanCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onResume;

  const DraftPlanCard({
    Key? key,
    required this.subscription,
    required this.onResume,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primaryLight.withOpacity(0.1),
      onTap: onResume,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.youHaveDraftPlan,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPlanName(subscription),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${StringConstants.duration}: ${subscription.durationInDays} days',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (subscription.isCustomized)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Customized',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            StringConstants.tapToResume,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  String _getPlanName(Subscription subscription) {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.nonVegetarian),
    );
    
    if (hasVegetarianMeals && !hasNonVegetarianMeals) {
      return StringConstants.vegetarianPlan;
    } else if (hasNonVegetarianMeals) {
      return StringConstants.nonVegetarianPlan;
    } else {
      return 'Custom Plan';
    }
  }
}