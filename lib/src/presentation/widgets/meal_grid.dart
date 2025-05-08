// lib/src/presentation/widgets/meal_grid.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/meal_slot_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

import '../screens/orders/meal_detail_screen.dart';

class MealGrid extends StatelessWidget {
  final List<MealSlot> mealSlots;
  final Subscription subscription;
  final bool isCompact;

  const MealGrid({
    super.key,
    required this.mealSlots,
    required this.subscription,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out slots without meals
    final slotsWithMeals =
        mealSlots.where((slot) => slot.meal != null).toList();

    if (slotsWithMeals.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meals scheduled',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    // Sort slots by day and timing
    slotsWithMeals.sort((a, b) {
      final days = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];
      final timings = ['breakfast', 'lunch', 'dinner'];

      int dayComparison = days
          .indexOf(a.day.toLowerCase())
          .compareTo(days.indexOf(b.day.toLowerCase()));
      if (dayComparison != 0) return dayComparison;

      return timings
          .indexOf(a.timing.toLowerCase())
          .compareTo(timings.indexOf(b.timing.toLowerCase()));
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 2 : 1,
        childAspectRatio: isCompact ? 0.8 : 2.5,
        crossAxisSpacing: AppDimensions.marginMedium,
        mainAxisSpacing: AppDimensions.marginMedium,
      ),
      itemCount: slotsWithMeals.length,
      itemBuilder: (context, index) {
        final slot = slotsWithMeals[index];
        return MealGridItem(
          slot: slot,
          subscription: subscription,
          isCompact: isCompact,
        );
      },
    );
  }
}

class MealGridItem extends StatelessWidget {
  final MealSlot slot;
  final Subscription subscription;
  final bool isCompact;

  const MealGridItem({
    Key? key,
    required this.slot,
    required this.subscription,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meal = slot.meal!;

    return InkWell(
      onTap: () {
        // Convert MealSlot to Order for the detail screen
        final order = _createOrderFromSlot(slot, subscription);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailScreen(order: order),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: isCompact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  Widget _buildCompactContent() {
    final meal = slot.meal!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        AspectRatio(
          aspectRatio: 1.5,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusMedium),
            ),
            child:
                meal.imageUrl != null
                    ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              _getMealIcon(slot.timing),
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                    )
                    : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getMealIcon(slot.timing),
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getMealColor(slot.timing).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_formatDay(slot.day)} • ${_formatTiming(slot.timing)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getMealColor(slot.timing),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Modifications to fix overflow issues in MealGridItem
  Widget _buildFullContent() {
    final meal = slot.meal!;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Changed to start alignment
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: SizedBox(
            width: 120,
            height: double.infinity,
            child:
                meal.imageUrl != null
                    ? Image.network(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              _getMealIcon(slot.timing),
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                    )
                    : Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        _getMealIcon(slot.timing),
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      // Wrapped in Flexible
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMealColor(slot.timing).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMealIcon(slot.timing),
                              size: 14,
                              color: _getMealColor(slot.timing),
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatTiming(slot.timing),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getMealColor(slot.timing),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatDay(slot.day),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Added overflow handling
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  meal.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Flexible(
                  // Wrapped in Flexible to allow shrinking
                  child: Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 0),
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    Text(
                      meal.price.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Order _createOrderFromSlot(MealSlot slot, Subscription subscription) {
    // Calculate the date based on the subscription start date and the day
    final date = _calculateDateForSlot(slot, subscription);

    return Order(
      meal: slot.meal!,
      timing: slot.timing,
      subscriptionId: subscription.id,
      date: date,
      status: _determineOrderStatus(date),
      deliveredAt: null,
    );
  }

  DateTime _calculateDateForSlot(MealSlot slot, Subscription subscription) {
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final slotDayIndex = days.indexOf(slot.day.toLowerCase());

    // Start from subscription start date
    DateTime date = subscription.startDate;

    // Find the first occurrence of the slot's day
    while (date.weekday - 1 != slotDayIndex) {
      date = date.add(Duration(days: 1));
    }

    return date;
  }

  OrderStatus _determineOrderStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);

    if (orderDate.isBefore(today)) {
      return OrderStatus.delivered;
    } else {
      return OrderStatus.coming;
    }
  }

  IconData _getMealIcon(String timing) {
    switch (timing.toLowerCase()) {
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

  Color _getMealColor(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return AppColors.accent;
      case 'dinner':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _formatDay(String day) {
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }

  String _formatTiming(String timing) {
    return timing.substring(0, 1).toUpperCase() + timing.substring(1);
  }
}
