// lib/src/presentation/widgets/subscription_widgets.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/week_plan.dart';

// Widget to display meals in a subscription (handles week structure)
class SubscriptionMealGrid extends StatelessWidget {
  final Subscription subscription;
  final bool isCompact;

  const SubscriptionMealGrid({
    super.key,
    required this.subscription,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meal schedule available',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    if (isCompact) {
      return _buildCompactView(context);
    } else {
      return _buildDetailedView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          subscription.weeks!.map((weekPlan) {
            return Card(
              margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${weekPlan.week}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (weekPlan.package != null)
                      Text(
                        weekPlan.package!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      '${weekPlan.totalMeals} meals scheduled',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return Column(
      children:
          subscription.weeks!.map((weekPlan) {
            return _buildWeekSection(context, weekPlan);
          }).toList(),
    );
  }

  Widget _buildWeekSection(BuildContext context, WeekPlan weekPlan) {
    // Group slots by day
    final Map<String, List<MealSlot>> slotsByDay = {};
    for (final slot in weekPlan.slots) {
      final day = slot.day.toLowerCase();
      slotsByDay.putIfAbsent(day, () => []);
      slotsByDay[day]!.add(slot);
    }

    // Sort days
    final sortedDays = _getSortedDays(slotsByDay.keys.toList());

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginLarge),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week header
            Container(
              padding: EdgeInsets.only(bottom: AppDimensions.marginMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week ${weekPlan.week}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (weekPlan.package != null)
                    Chip(
                      label: Text(
                        weekPlan.package!.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                    ),
                ],
              ),
            ),

            // Days with meals
            ...sortedDays.map((day) {
              final daySlots = slotsByDay[day]!;
              return _buildDayRow(context, day, daySlots);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, String day, List<MealSlot> slots) {
    // Sort slots by timing
    slots.sort(
      (a, b) => _getMealTimeOrder(a.timing) - _getMealTimeOrder(b.timing),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDay(day),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ...slots.map((slot) => _buildMealItem(context, slot)).toList(),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, MealSlot slot) {
    final mealName = slot.meal?.name ?? 'Meal Selected';
    final timing = _formatTiming(slot.timing);
    final color = _getTimingColor(slot.timing);

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        bottom: AppDimensions.marginSmall,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusSmall,
              ),
            ),
            child: Text(
              timing,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Expanded(child: Text(mealName, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  List<String> _getSortedDays(List<String> days) {
    const sortedDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return sortedDays.where((day) => days.contains(day)).toList();
  }

  int _getMealTimeOrder(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      default:
        return 3;
    }
  }

  String _formatDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }

  String _formatTiming(String timing) {
    return timing.substring(0, 1).toUpperCase() + timing.substring(1);
  }

  Color _getTimingColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.primary;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}

// Widget to display subscription status summary
class SubscriptionStatusSummary extends StatelessWidget {
  final Subscription subscription;
  final int daysRemaining;

  const SubscriptionStatusSummary({
    super.key,
    required this.subscription,
    required this.daysRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = subscription.isActive;
    final isPaused = subscription.isPaused;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(),
                SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginMedium),

            // Key information
            _buildInfoRow('Start Date', _formatDate(subscription.startDate)),
            _buildInfoRow(
              'End Date',
              _formatDate(
                subscription.calculatedEndDate ?? subscription.startDate,
              ),
            ),
            _buildInfoRow('Days Remaining', '$daysRemaining days'),
            _buildInfoRow('Total Meals', '${subscription.totalSlots}'),
            if (subscription.paymentStatus == PaymentStatus.paid)
              _buildInfoRow('Payment', 'Paid', valueColor: AppColors.success),

            SizedBox(height: AppDimensions.marginMedium),

            // Progress indicator
            LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (subscription.isPaused) return 'Paused';

    switch (subscription.status) {
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

  Color _getStatusColor() {
    if (subscription.isPaused) return AppColors.warning;

    switch (subscription.status) {
      case SubscriptionStatus.pending:
        return AppColors.warning;
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

  double _calculateProgress() {
    if (subscription.durationDays <= 0) return 0.0;
    final daysCompleted = subscription.durationDays - daysRemaining;
    return (daysCompleted / subscription.durationDays).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
