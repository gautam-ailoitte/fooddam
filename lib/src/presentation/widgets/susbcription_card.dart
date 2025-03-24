// lib/features/subscriptions/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

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
    final bool isActive = subscription.status == SubscriptionStatus.active && !subscription.isPaused;
    final bool isPaused = subscription.isPaused || subscription.status == SubscriptionStatus.paused;

    // Calculate some useful metrics
    final totalMeals = subscription.slots.length;
    final endDate = subscription.startDate.add(Duration(days: subscription.durationDays));
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
    
    // Count meals by type
    final breakfastCount = subscription.slots.where((slot) => 
      slot.timing.toLowerCase() == 'breakfast').length;
    final lunchCount = subscription.slots.where((slot) => 
      slot.timing.toLowerCase() == 'lunch').length;
    final dinnerCount = subscription.slots.where((slot) => 
      slot.timing.toLowerCase() == 'dinner').length;

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and title row
              Row(
                children: [
                  _buildStatusIndicator(
                    isPaused 
                        ? AppColors.warning 
                        : isActive 
                            ? AppColors.success 
                            : AppColors.textSecondary,
                  ),
                  SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Text(
                      'Weekly Subscription',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPaused 
                          ? AppColors.warning.withOpacity(0.1)
                          : isActive 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
                    ),
                    child: Text(
                      isPaused 
                          ? 'Paused'
                          : isActive 
                              ? 'Active'
                              : _getStatusText(subscription.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPaused 
                            ? AppColors.warning
                            : isActive 
                                ? AppColors.success
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Subscription details
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    totalMeals.toString(),
                    'Meals',
                    Icons.restaurant_menu,
                  ),
                  SizedBox(width: AppDimensions.marginMedium),
                  _buildInfoItem(
                    context,
                    daysRemaining > 0 ? '$daysRemaining days' : 'Ended',
                    'Remaining',
                    Icons.calendar_today,
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Meal breakdown
              Row(
                children: [
                  Icon(
                    Icons.breakfast_dining,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$breakfastCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(width: AppDimensions.marginMedium),
                  
                  Icon(
                    Icons.lunch_dining,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$lunchCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(width: AppDimensions.marginMedium),
                  
                  Icon(
                    Icons.dinner_dining,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$dinnerCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginMedium),
              
              // Delivery address summary
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${subscription.address.street}, ${subscription.address.city}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.marginSmall),
              
              // Dates
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${DateFormat('MMM d, y').format(subscription.startDate)} - ${DateFormat('MMM d, y').format(endDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              SizedBox(height: AppDimensions.marginMedium),
              
              // View details button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 16,
                  ),
                  label: Text('View Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary, padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginMedium,
                      vertical: AppDimensions.marginSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        SizedBox(width: AppDimensions.marginSmall),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }
}