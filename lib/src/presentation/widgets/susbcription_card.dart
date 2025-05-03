import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({super.key, required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isActive =
        subscription.status == SubscriptionStatus.active &&
        !subscription.isPaused;
    final bool isPaused =
        subscription.isPaused ||
        subscription.status == SubscriptionStatus.paused;

    // Calculate total meals and days remaining
    final totalMeals = subscription.slots.length;
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );
    final daysRemaining = endDate.difference(DateTime.now()).inDays;

    // Count meals by type
    final breakfastCount =
        subscription.slots
            .where((slot) => slot.timing.toLowerCase() == 'breakfast')
            .length;
    final lunchCount =
        subscription.slots
            .where((slot) => slot.timing.toLowerCase() == 'lunch')
            .length;
    final dinnerCount =
        subscription.slots
            .where((slot) => slot.timing.toLowerCase() == 'dinner')
            .length;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isPaused
                            ? [
                              AppColors.warning.withOpacity(0.7),
                              AppColors.warning,
                            ]
                            : isActive
                            ? [
                              AppColors.primary.withOpacity(0.7),
                              AppColors.primary,
                            ]
                            : [Colors.grey.shade300, Colors.grey.shade400],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Subscription',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isPaused
                                      ? 'PAUSED'
                                      : isActive
                                      ? 'ACTIVE'
                                      : _getStatusText(subscription.status),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '$daysRemaining days remaining',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isPaused ? Icons.pause : Icons.restaurant,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subscription details
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal statistics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // _buildStatItem(
                        //   context,
                        //   label: 'Total Meals',
                        //   value: '$totalMeals',
                        //   icon: Icons.restaurant_menu,
                        //   color: AppColors.primary,
                        // ),
                        _buildStatItem(
                          context,
                          label: 'Breakfast',
                          value: '$breakfastCount',
                          icon: Icons.free_breakfast,
                          color: Colors.orange,
                        ),
                        _buildStatItem(
                          context,
                          label: 'Lunch',
                          value: '$lunchCount',
                          icon: Icons.lunch_dining,
                          color: AppColors.accent,
                        ),
                        _buildStatItem(
                          context,
                          label: 'Dinner',
                          value: '$dinnerCount',
                          icon: Icons.dinner_dining,
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 12),

                    // Delivery address
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${subscription.address.street}, ${subscription.address.city}',
                                style: TextStyle(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Date range
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${DateFormat('d MMM, yyyy').format(subscription.startDate)} - ${DateFormat('d MMM, yyyy').format(endDate)}',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Action button
                    Row(
                      children: [
                        Expanded(
                          child:
                              isPaused
                                  ? _buildActionButton(
                                    label: 'Resume Subscription',
                                    icon: Icons.play_arrow,
                                    color: AppColors.success,
                                    onPressed: onTap,
                                  )
                                  : _buildActionButton(
                                    label: 'View Details',
                                    icon: Icons.arrow_forward,
                                    color: AppColors.primary,
                                    onPressed: onTap,
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
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        // Text(
        //   value,
        //   style: TextStyle(
        //     fontWeight: FontWeight.bold,
        //     fontSize: 16,
        //   ),
        // ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  String _getStatusText(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.pending:
        return 'PENDING';
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.paused:
        return 'PAUSED';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
    }
  }
}
