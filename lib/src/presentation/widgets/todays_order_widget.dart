// lib/src/presentation/widgets/today_orders_widget.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

class TodayOrdersWidget extends StatelessWidget {
  final Map<String, List<Order>> ordersByType;
  final String currentMealPeriod;

  const TodayOrdersWidget({
    super.key,
    required this.ordersByType,
    required this.currentMealPeriod,
  });

  @override
  Widget build(BuildContext context) {
    // Get meal types that have orders
    final mealTypes =
        ordersByType.keys
            .where((type) => ordersByType[type]!.isNotEmpty)
            .toList();

    return Column(
      children: [
        // First show current meal period
        if (ordersByType[currentMealPeriod]?.isNotEmpty ?? false) ...[
          _buildMealSection(
            context,
            currentMealPeriod,
            ordersByType[currentMealPeriod]!,
            true,
          ),
        ],

        // Then show other meal periods
        ...mealTypes
            .where((type) => type != currentMealPeriod)
            .map(
              (type) =>
                  _buildMealSection(context, type, ordersByType[type]!, false),
            ),
      ],
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String mealType,
    List<Order> orders,
    bool isCurrent,
  ) {
    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        right: AppDimensions.marginMedium,
        bottom: AppDimensions.marginMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                mealType,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (isCurrent) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    'Current',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ...orders.map((order) => _buildOrderItem(context, order)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    final isUpcoming = order.status == OrderStatus.coming;
    final iconData = isUpcoming ? Icons.access_time : Icons.check_circle;
    final iconColor = isUpcoming ? AppColors.warning : AppColors.success;

    // Determine delivery time based on meal timing
    DateTime expectedTime;
    if (order.isBreakfast) {
      expectedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        8,
        0,
      );
    } else if (order.isLunch) {
      expectedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        12,
        30,
      );
    } else {
      expectedTime = DateTime(
        order.date.year,
        order.date.month,
        order.date.day,
        19,
        0,
      );
    }

    final statusText =
        isUpcoming
            ? 'Coming soon - Expected at ${_formatTime(expectedTime)}'
            : 'Delivered at ${_formatTime(order.deliveredAt ?? expectedTime)}';

    return Card(
      margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image or placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
                image:
                    order.meal.imageUrl != null &&
                            order.meal.imageUrl!.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(order.meal.imageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  order.meal.imageUrl == null || order.meal.imageUrl!.isEmpty
                      ? Icon(
                        Icons.restaurant,
                        color: AppColors.primary,
                        size: 32,
                      )
                      : null,
            ),
            SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(iconData, size: 16, color: iconColor),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          statusText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: iconColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
