// lib/src/presentation/widgets/todays_order_widget.dart (UPDATED)
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
            .where((type) => ordersByType[type]?.isNotEmpty ?? false)
            .toList();

    if (mealTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Text(
            'No meals found for today',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

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
    final mealColor = _getMealTypeColor(mealType);

    return Container(
      margin: EdgeInsets.only(
        left: AppDimensions.marginMedium,
        right: AppDimensions.marginMedium,
        bottom: AppDimensions.marginMedium,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        color: isCurrent ? mealColor.withOpacity(0.05) : null,
        border:
            isCurrent
                ? Border.all(color: mealColor.withOpacity(0.3), width: 1)
                : null,
      ),
      padding: isCurrent ? EdgeInsets.all(AppDimensions.marginMedium) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getMealTypeIcon(mealType), color: mealColor, size: 20),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                mealType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mealColor,
                ),
              ),
              if (isCurrent) ...[
                SizedBox(width: AppDimensions.marginSmall),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginSmall,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: mealColor,
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
                const Spacer(),
                _buildTimeDisplay(mealType),
              ],
            ],
          ),
          SizedBox(height: AppDimensions.marginSmall),
          ...orders.map((order) => _buildOrderItem(context, order, mealType)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order, String mealType) {
    final isUpcoming = order.isPending;
    final iconData = isUpcoming ? Icons.access_time : Icons.check_circle;
    final iconColor = isUpcoming ? AppColors.warning : AppColors.success;
    final mealColor = _getMealTypeColor(mealType);

    // Use estimated delivery time from order entity
    final expectedTime = order.estimatedDeliveryTime ?? order.deliveryDate;

    final statusText =
        isUpcoming
            ? 'Coming soon - Expected at ${_formatTime(expectedTime)}'
            : 'Delivered at ${_formatTime(expectedTime)}';

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OrderMealDetailScreen(order: order),
        //   ),
        // );
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: AppDimensions.marginSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image or placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(color: mealColor.withOpacity(0.1)),
                  child:
                      order.dish?.imageUrl != null &&
                              order.dish!.imageUrl!.isNotEmpty
                          ? Image.network(
                            order.dish!.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  _getMealTypeIcon(mealType),
                                  color: mealColor,
                                  size: 32,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                  color: mealColor,
                                ),
                              );
                            },
                          )
                          : Center(
                            child: Icon(
                              _getMealTypeIcon(mealType),
                              color: mealColor,
                              size: 32,
                            ),
                          ),
                ),
              ),
              SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.dish?.name ?? 'Unknown Dish',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.dish?.description != null &&
                        order.dish!.description.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        order.dish!.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: AppDimensions.marginSmall),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(iconData, size: 12, color: iconColor),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            statusText,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: iconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isUpcoming && order.minutesUntilDelivery > 0) ...[
                      SizedBox(height: AppDimensions.marginSmall),
                      LinearProgressIndicator(
                        value: _calculateDeliveryProgress(order, mealType),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String mealType) {
    final DateTime expectedTime = _getExpectedTimeForMeal(
      DateTime.now(),
      mealType,
    );
    final now = DateTime.now();

    Color textColor;
    String timeText;

    if (now.hour > expectedTime.hour ||
        (now.hour == expectedTime.hour && now.minute > expectedTime.minute)) {
      // Past time
      textColor = Colors.grey;
      timeText = 'Today ${_formatTime(expectedTime)}';
    } else {
      // Future time
      textColor = AppColors.primary;
      final minutesRemaining = expectedTime.difference(now).inMinutes;

      if (minutesRemaining < 60) {
        timeText = 'In $minutesRemaining min';
      } else {
        final hoursRemaining = (minutesRemaining / 60).floor();
        final remainingMinutes = minutesRemaining % 60;
        timeText = 'In ${hoursRemaining}h ${remainingMinutes}m';
      }
    }

    return Text(
      timeText,
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
    );
  }

  // Helper methods
  DateTime _getExpectedTimeForMeal(DateTime date, String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return DateTime(date.year, date.month, date.day, 8, 0);
      case 'lunch':
        return DateTime(date.year, date.month, date.day, 12, 30);
      case 'dinner':
        return DateTime(date.year, date.month, date.day, 19, 0);
      default:
        return DateTime(date.year, date.month, date.day, 12, 0);
    }
  }

  double _calculateDeliveryProgress(Order order, String mealType) {
    final expectedTime =
        order.estimatedDeliveryTime ??
        _getExpectedTimeForMeal(order.deliveryDate ?? DateTime.now(), mealType);
    final mealDuration = _getMealDuration(mealType);
    final now = DateTime.now();

    // Calculate start time (preparation time before expected time)
    final startTime = expectedTime.subtract(Duration(minutes: mealDuration));

    // If we're before the start time
    if (now.isBefore(startTime)) {
      return 0.0;
    }

    // If we're after the expected time
    if (now.isAfter(expectedTime)) {
      return 1.0;
    }

    // Calculate progress
    final totalMinutes = mealDuration;
    final elapsedMinutes = startTime.difference(now).inMinutes.abs();

    return elapsedMinutes / totalMinutes;
  }

  int _getMealDuration(String mealType) {
    // Default preparation durations in minutes
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 90; // 1.5 hours
      case 'lunch':
        return 120; // 2 hours
      case 'dinner':
        return 120; // 2 hours
      default:
        return 120;
    }
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

  String? _formatTime(DateTime? time) {
    if (time == null) return null;
    final hour =
        time.hour > 12
            ? time.hour - 12
            : time.hour == 0
            ? 12
            : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
