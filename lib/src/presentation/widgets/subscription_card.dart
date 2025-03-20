// lib/src/presentation/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/subscription_entity.dart';
import 'package:foodam/src/presentation/utlis/date_formatter.dart';
import 'package:foodam/src/presentation/utlis/plan_duration_calcluator.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;
  
  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormatter dateFormatter = DateFormatter();
    final PlanDurationCalculator durationCalculator = PlanDurationCalculator();
    
    final daysRemaining = durationCalculator.calculateRemainingDays(subscription.endDate);
    final completionPercentage = durationCalculator.calculateCompletionPercentage(
      subscription.startDate, 
      subscription.endDate
    );
    
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Plan icon/image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPlanIcon(),
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              AppSpacing.hMd,
              // Plan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.subscriptionPlan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getDaysText(daysRemaining),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: daysRemaining > 0 ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          AppSpacing.vMd,
          
          // Date range
          Row(
            children: [
              Icon(
                Icons.date_range,
                size: 16,
                color: AppColors.textSecondary,
              ),
              AppSpacing.hSm,
              Text(
                '${StringConstants.startDate} ${dateFormatter.formatShortDate(subscription.startDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.hMd,
              Icon(
                Icons.date_range,
                size: 16,
                color: AppColors.textSecondary,
              ),
              AppSpacing.hSm,
              Text(
                '${StringConstants.endDate} ${dateFormatter.formatShortDate(subscription.endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          AppSpacing.vMd,
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${completionPercentage.toStringAsFixed(0)}% ${StringConstants.completed}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _getDaysRemainingText(daysRemaining),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: completionPercentage / 100,
                backgroundColor: AppColors.backgroundDark,
                valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(daysRemaining)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPlanIcon() {
    if (subscription.subscriptionPlan.name.toLowerCase().contains('vegetarian') ||
        subscription.subscriptionPlan.name.toLowerCase().contains('veg')) {
      return Icons.eco;
    } else if (subscription.subscriptionPlan.name.toLowerCase().contains('non-veg')) {
      return Icons.restaurant;
    } else if (subscription.subscriptionPlan.name.toLowerCase().contains('premium') ||
               subscription.subscriptionPlan.name.toLowerCase().contains('deluxe')) {
      return Icons.star;
    }
    return Icons.restaurant_menu;
  }

  String _getStatusText() {
    if (subscription.isPaused) {
      return StringConstants.paused;
    }
    
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return StringConstants.active;
      case SubscriptionStatus.paused:
        return StringConstants.paused;
      case SubscriptionStatus.cancelled:
        return StringConstants.cancelled;
      case SubscriptionStatus.expired:
        return StringConstants.expired;
    }
  }

  Color _getStatusColor() {
    if (subscription.isPaused) {
      return AppColors.warning;
    }
    
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
    }
  }

  Color _getProgressColor(int daysRemaining) {
    if (daysRemaining <= 0) {
      return AppColors.error;
    } else if (daysRemaining <= 3) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  String _getDaysText(int daysRemaining) {
    if (daysRemaining <= 0) {
      return StringConstants.planExpired;
    } else if (daysRemaining == 1) {
      return StringConstants.lastDayPlan;
    } else {
      return '$daysRemaining ${StringConstants.daysRemaining}';
    }
  }

  String _getDaysRemainingText(int daysRemaining) {
    if (daysRemaining <= 0) {
      return StringConstants.expired;
    } else if (daysRemaining == 1) {
      return '1 ${StringConstants.day}';
    } else {
      return '$daysRemaining ${StringConstants.days}';
    }
  }
}