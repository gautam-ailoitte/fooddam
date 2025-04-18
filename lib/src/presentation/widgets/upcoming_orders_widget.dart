// lib/src/presentation/widgets/upcoming_orders_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';

class UpcomingOrdersWidget extends StatelessWidget {
  final Map<DateTime, List<Order>> ordersByDate;

  const UpcomingOrdersWidget({super.key, required this.ordersByDate});

  @override
  Widget build(BuildContext context) {
    if (ordersByDate.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No upcoming orders found',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Sort dates chronologically
    final dates = ordersByDate.keys.toList()..sort();

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final orders = ordersByDate[date]!;
        return _buildDateSection(context, date, orders);
      },
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    DateTime date,
    List<Order> orders,
  ) {
    final isToday = _isToday(date);
    final isTomorrow = _isTomorrow(date);

    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isTomorrow) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('EEEE, MMMM d').format(date);
    }

    Color sectionColor =
        isToday
            ? AppColors.primary
            : isTomorrow
            ? AppColors.accent
            : Colors.grey.shade700;

    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        right: AppDimensions.marginMedium,
        bottom: AppDimensions.marginLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sectionColor,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${orders.length} meal${orders.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ...orders.map((order) => _buildOrderItem(context, order, isToday)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order, bool isToday) {
    final Color accentColor = _getMealTypeColor(order.timing);
    final IconData mealIcon = _getMealTypeIcon(order.timing);

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal type indicator with icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Meal icon
                  Icon(mealIcon, color: accentColor, size: 32),

                  // Meal timing badge
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        _formatMealTimingShort(order.timing),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.mealType,
                        style: TextStyle(
                          fontSize: 14,
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getFormattedTime(order),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.meal.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (order.meal.description.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      order.meal.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isToday) ...[
                    SizedBox(height: 8),
                    _buildDeliveryInfo(context, order),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, Order order) {
    final minutesRemaining = order.minutesUntilDelivery;
    final bool isComingSoon = minutesRemaining < 60;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isComingSoon
                ? AppColors.warning.withOpacity(0.1)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isComingSoon
                  ? AppColors.warning.withOpacity(0.3)
                  : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isComingSoon ? Icons.delivery_dining : Icons.access_time,
            size: 16,
            color: isComingSoon ? AppColors.warning : AppColors.textSecondary,
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              isComingSoon
                  ? 'Arriving in ${_formatRemainingTime(minutesRemaining)}'
                  : 'Expected in ${_formatRemainingTime(minutesRemaining)}',
              style: TextStyle(
                fontSize: 12,
                color:
                    isComingSoon ? AppColors.warning : AppColors.textSecondary,
                fontWeight: isComingSoon ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  IconData _getMealTypeIcon(String timing) {
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

  Color _getMealTypeColor(String timing) {
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

  String _formatMealTimingShort(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return 'BF';
      case 'lunch':
        return 'LN';
      case 'dinner':
        return 'DN';
      default:
        return timing.substring(0, 2).toUpperCase();
    }
  }

  String _getFormattedTime(Order order) {
    // Estimate delivery time based on meal timing
    DateTime estimatedTime;
    if (order.isBreakfast) {
      estimatedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        8,
        0,
      );
    } else if (order.isLunch) {
      estimatedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        12,
        30,
      );
    } else {
      estimatedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        19,
        0,
      );
    }

    final hour =
        estimatedTime.hour > 12 ? estimatedTime.hour - 12 : estimatedTime.hour;
    final period = estimatedTime.hour >= 12 ? 'PM' : 'AM';
    final minute = estimatedTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatRemainingTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours hr${hours > 1 ? 's' : ''} $remainingMinutes min';
    }
  }
}
