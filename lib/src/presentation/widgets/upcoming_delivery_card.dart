// lib/src/presentation/widgets/home/upcoming_delivery_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

class UpcomingDeliveryCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const UpcomingDeliveryCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(order.deliveryDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _buildStatusBadge(context, order.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildMealList(context, order.meals),
          const SizedBox(height: 12),
          Text(
            'Delivery to: ${order.deliveryAddress.street}, ${order.deliveryAddress.city}',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, OrderStatus status) {
    final Color color;
    final String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        text = 'Confirmed';
        break;
      case OrderStatus.preparing:
        color = AppColors.accent;
        text = 'Preparing';
        break;
      case OrderStatus.ready:
        color = AppColors.success;
        text = 'Ready';
        break;
      case OrderStatus.outForDelivery:
        color = AppColors.primary;
        text = 'On Way';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildMealList(BuildContext context, List<OrderedMeal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meals.map((meal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: meal.dietPreference.toLowerCase() == 'vegetarian'
                      ? AppColors.vegetarian
                      : AppColors.nonVegetarian,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${meal.mealType.substring(0, 1).toUpperCase()}${meal.mealType.substring(1)} (${meal.quantity})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    // Format date to show weekday, day, month
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    return '$weekday, $day $month';
  }
}