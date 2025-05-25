// lib/src/presentation/screens/orders/meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

class OrderMealDetailScreen extends StatelessWidget {
  final Order order;

  const OrderMealDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final Color mealColor = _getMealTypeColor(order.timing ?? 'lunch');
    final bool isUpcoming = order.isPending;
    final bool isToday = order.isToday;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(order.mealType),
        backgroundColor: mealColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with meal image and basic info
            _buildHeaderSection(context, mealColor),

            // Delivery information
            _buildDeliverySection(context, mealColor, isUpcoming, isToday),

            // Dish details
            _buildDishSection(context),

            // Order details
            _buildOrderDetailsSection(context),

            // Delivery address
            if (order.address != null) _buildAddressSection(context),

            // Cloud kitchen info
            if (order.cloudKitchen != null) _buildCloudKitchenSection(context),

            // Delivery instructions
            if (order.deliveryInstructions != null &&
                order.deliveryInstructions!.isNotEmpty)
              _buildInstructionsSection(context),

            SizedBox(height: AppDimensions.marginLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Color mealColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: mealColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.borderRadiusLarge),
          bottomRight: Radius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
      child: Column(
        children: [
          // Meal image
          Container(
            height: 200,
            width: double.infinity,
            margin: EdgeInsets.all(AppDimensions.marginMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              color: Colors.white.withOpacity(0.1),
            ),
            child:
                order.dish?.imageUrl != null && order.dish!.imageUrl!.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium,
                      ),
                      child: Image.network(
                        order.dish!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(mealColor);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                    : _buildPlaceholderImage(mealColor),
          ),

          // Meal name and timing
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.marginMedium,
              0,
              AppDimensions.marginMedium,
              AppDimensions.marginLarge,
            ),
            child: Column(
              children: [
                Text(
                  order.dish?.name ?? 'Unknown Dish',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.marginSmall),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                    vertical: AppDimensions.marginSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusLarge,
                    ),
                  ),
                  child: Text(
                    '${order.mealType} • ${order.formattedDeliveryDate}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Color mealColor) {
    return Center(
      child: Icon(
        _getMealTypeIcon(order.timing ?? 'lunch'),
        size: 80,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  Widget _buildDeliverySection(
    BuildContext context,
    Color mealColor,
    bool isUpcoming,
    bool isToday,
  ) {
    final estimatedTime = order.estimatedDeliveryTime;
    final statusColor = isUpcoming ? AppColors.warning : AppColors.success;
    final statusIcon = isUpcoming ? Icons.access_time : Icons.check_circle;

    return Container(
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                'Delivery Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            order.statusText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (estimatedTime != null) ...[
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Expected time: ${_formatTime(estimatedTime)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (isUpcoming && isToday && order.minutesUntilDelivery > 0) ...[
            SizedBox(height: AppDimensions.marginMedium),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  'Arriving in ${_formatRemainingTime(order.minutesUntilDelivery)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: AppDimensions.marginSmall),
            LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDishSection(BuildContext context) {
    if (order.dish == null) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: 'Dish Details',
      icon: Icons.restaurant_menu,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.dish!.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (order.dish!.description.isNotEmpty) ...[
            SizedBox(height: AppDimensions.marginSmall),
            Text(
              order.dish!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (order.dish!.dietaryPreferences.isNotEmpty) ...[
            SizedBox(height: AppDimensions.marginMedium),
            Wrap(
              spacing: AppDimensions.marginSmall,
              runSpacing: AppDimensions.marginSmall,
              children:
                  order.dish!.dietaryPreferences.map((pref) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.marginMedium,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusLarge,
                        ),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        pref.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Order Details',
      icon: Icons.receipt,
      child: Column(
        children: [
          if (order.orderNumber != null) ...[
            _buildDetailRow(context, 'Order Number', order.orderNumber!),
            SizedBox(height: AppDimensions.marginSmall),
          ],
          if (order.id != null) ...[
            _buildDetailRow(context, 'Order ID', order.id!),
            SizedBox(height: AppDimensions.marginSmall),
          ],
          if (order.noOfPersons != null) ...[
            _buildDetailRow(
              context,
              'Serves',
              '${order.noOfPersons} person${order.noOfPersons! > 1 ? 's' : ''}',
            ),
            SizedBox(height: AppDimensions.marginSmall),
          ],
          _buildDetailRow(context, 'Meal Type', order.mealType),
          SizedBox(height: AppDimensions.marginSmall),
          _buildDetailRow(
            context,
            'Delivery Date',
            order.formattedDeliveryDate,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    final address = order.address!;
    final fullAddress =
        '${address.street}, ${address.city}, ${address.state} ${address.zipCode}';

    return _buildSection(
      context,
      title: 'Delivery Address',
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullAddress,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (address.country != null) ...[
            SizedBox(height: 4),
            Text(
              address.country!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloudKitchenSection(BuildContext context) {
    final kitchen = order.cloudKitchen!;

    return _buildSection(
      context,
      title: 'Prepared By',
      icon: Icons.store,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kitchen.displayName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (kitchen.address != null) ...[
            SizedBox(height: 4),
            Text(
              kitchen.location,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Delivery Instructions',
      icon: Icons.info_outline,
      child: Text(
        order.deliveryInstructions!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.marginMedium,
        vertical: AppDimensions.marginSmall,
      ),
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginMedium),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: AppDimensions.marginMedium),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
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

  String _formatTime(DateTime time) {
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

  String _formatRemainingTime(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}';
    }
  }

  double _calculateProgress() {
    if (order.estimatedDeliveryTime == null) return 0.0;

    final now = DateTime.now();
    final estimated = order.estimatedDeliveryTime!;
    final start = estimated.subtract(
      const Duration(hours: 2),
    ); // 2 hours before

    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(estimated)) return 1.0;

    final total = estimated.difference(start).inMinutes;
    final elapsed = now.difference(start).inMinutes;

    return elapsed / total;
  }
}
