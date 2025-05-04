// lib/src/presentation/screens/meal/meal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:intl/intl.dart';

class MealDetailScreen extends StatelessWidget {
  final Order order;

  const MealDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                order.meal.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Meal Image
                  if (order.meal.imageUrl != null &&
                      order.meal.imageUrl!.isNotEmpty)
                    Image.network(
                      order.meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary,
                          child: Icon(
                            _getMealTypeIcon(order.timing),
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.primary,
                      child: Icon(
                        _getMealTypeIcon(order.timing),
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.marginLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Meal Info Section
                  _buildSectionTitle('Meal Information'),
                  SizedBox(height: AppDimensions.marginSmall),
                  _buildInfoCard(),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Description Section
                  if (order.meal.description.isNotEmpty) ...[
                    _buildSectionTitle('Description'),
                    SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      order.meal.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: AppDimensions.marginLarge),
                  ],

                  // Delivery Details Section
                  _buildSectionTitle('Delivery Details'),
                  SizedBox(height: AppDimensions.marginSmall),
                  _buildDeliveryDetails(context),
                  SizedBox(height: AppDimensions.marginLarge),

                  // Price Section
                  _buildSectionTitle('Price'),
                  SizedBox(height: AppDimensions.marginSmall),
                  _buildPriceCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isDelivered = order.status == OrderStatus.delivered;
    final color = isDelivered ? AppColors.success : AppColors.warning;
    final statusText = isDelivered ? 'Delivered' : 'Coming Soon';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDelivered ? Icons.check_circle : Icons.access_time,
            size: 16,
            color: color,
          ),
          SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          children: [
            _buildInfoRow(
              icon: _getMealTypeIcon(order.timing),
              label: 'Meal Type',
              value: order.mealType,
              color: _getMealTypeColor(order.timing),
            ),
            Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(order.date),
              color: AppColors.primary,
            ),
            Divider(height: 24),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Time',
              value: order.timing,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDetails(BuildContext context) {
    final expectedTime = _getExpectedDeliveryTime();
    final isDelivered = order.status == OrderStatus.delivered;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDelivered ? Icons.check_circle : Icons.delivery_dining,
                  color: isDelivered ? AppColors.success : AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  isDelivered ? 'Delivered' : 'Expected Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              isDelivered
                  ? 'Delivered at ${_formatTime(order.deliveredAt ?? expectedTime)}'
                  : 'Expected at ${_formatTime(expectedTime)}',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            if (!isDelivered && order.minutesUntilDelivery > 0) ...[
              SizedBox(height: 16),
              LinearProgressIndicator(
                value: _calculateDeliveryProgress(),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              // SizedBox(height: 8),
              // Text(
              //   '${order.minutesUntilDelivery} minutes remaining',
              //   style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              // ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Card(
      elevation: 2,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Row(
          children: [
            Icon(Icons.currency_rupee, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text(
              order.meal.price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
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

  DateTime _getExpectedDeliveryTime() {
    switch (order.timing.toLowerCase()) {
      case 'breakfast':
        return DateTime(
          order.date.year,
          order.date.month,
          order.date.day,
          8,
          0,
        );
      case 'lunch':
        return DateTime(
          order.date.year,
          order.date.month,
          order.date.day,
          12,
          30,
        );
      case 'dinner':
        return DateTime(
          order.date.year,
          order.date.month,
          order.date.day,
          19,
          0,
        );
      default:
        return DateTime(
          order.date.year,
          order.date.month,
          order.date.day,
          12,
          0,
        );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  double _calculateDeliveryProgress() {
    if (order.status == OrderStatus.delivered) return 1.0;

    final expectedTime = _getExpectedDeliveryTime();
    final now = DateTime.now();
    final startTime = expectedTime.subtract(Duration(hours: 2));

    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(expectedTime)) return 1.0;

    final totalDuration = expectedTime.difference(startTime).inMinutes;
    final elapsedDuration = now.difference(startTime).inMinutes;

    return elapsedDuration / totalDuration;
  }
}
