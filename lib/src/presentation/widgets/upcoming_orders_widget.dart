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
                    color:
                        isToday
                            ? AppColors.primary
                            : isTomorrow
                            ? AppColors.accent
                            : Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    dateText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${orders.length} meals',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal type indicator with icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
              ),
              child: Center(
                child: Icon(
                  _getMealTypeIcon(order.timing),
                  color: accentColor,
                  size: 32,
                ),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getFormattedTime(order),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.meal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (order.meal.description.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      order.meal.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (isToday) ...[
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Expected in ${order.minutesUntilDelivery} minutes',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
}
