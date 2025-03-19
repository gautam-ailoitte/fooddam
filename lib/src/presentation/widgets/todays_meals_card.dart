// / lib/src/presentation/widgets/today_meals_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_card.dart';

class TodayMealsCard extends StatelessWidget {
  const TodayMealsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildMealItem(
            context,
            title: StringConstants.breakfast,
            time: StringConstants.breakfastTime,
            icon: Icons.free_breakfast,
            iconColor: Colors.orange,
          ),
          const Divider(height: 1),
          _buildMealItem(
            context,
            title: StringConstants.lunch,
            time: StringConstants.lunchTime,
            icon: Icons.lunch_dining,
            iconColor: Colors.green,
          ),
          const Divider(height: 1),
          _buildMealItem(
            context,
            title: StringConstants.dinner,
            time: StringConstants.dinnerTime,
            icon: Icons.dinner_dining,
            iconColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(
    BuildContext context, {
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigate to meal details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}