// lib/src/presentation/widgets/active_plan_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

import '../utlis/subscription_adapter.dart';

class ActivePlanCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const ActivePlanCard({super.key, required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    final nextDeliveryDate = SubscriptionAdapter.getNextDeliveryDate(
      subscription,
    );
    final daysRemaining = SubscriptionAdapter.calculateDaysRemaining(
      subscription,
    );
    final statusColor =
        subscription.isPaused ? AppColors.warning : AppColors.success;
    final statusText = subscription.isPaused ? 'Paused' : 'Active';
    final totalMeals = SubscriptionAdapter.getTotalMealCount(subscription);

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Weekly Subscription',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginSmall),
              Divider(),
              SizedBox(height: AppDimensions.marginSmall),
              if (nextDeliveryDate != null && !subscription.isPaused) ...[
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Next Delivery:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat('EEEE, MMMM d').format(nextDeliveryDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimensions.marginSmall),
              ],
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Subscription ends in:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$daysRemaining days',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginSmall),
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Total meals:',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$totalMeals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginMedium),
              if (!subscription.isPaused) ...[
                OutlinedButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.visibility_outlined),
                  label: Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.play_arrow),
                  label: Text('Resume Subscription'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
