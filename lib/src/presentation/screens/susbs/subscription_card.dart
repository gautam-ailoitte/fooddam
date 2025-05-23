// lib/src/presentation/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:intl/intl.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback? onPayPressed;
  final bool showPayButton;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
    this.onPayPressed,
    this.showPayButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive =
        subscription.status == SubscriptionStatus.active &&
        !subscription.isPaused;
    final bool isPending = subscription.status == SubscriptionStatus.pending;
    final bool isPaused =
        subscription.isPaused ||
        subscription.status == SubscriptionStatus.paused;
    final bool needsPayment =
        isPending && subscription.paymentStatus == PaymentStatus.pending;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          child: Container(
            decoration: EnhancedTheme.cardDecoration.copyWith(
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Header with status
                Container(
                  padding: EdgeInsets.all(AppDimensions.marginMedium),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.05),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.borderRadiusLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: AppDimensions.marginSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                            Text(
                              'Subscription #${_getShortId()}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showPayButton && needsPayment && onPayPressed != null)
                        _buildPayButton(),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppDimensions.marginMedium),
                  child: Column(
                    children: [
                      // Date and duration info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.calendar_today,
                              label: 'Start Date',
                              value: DateFormat(
                                'MMM d, yyyy',
                              ).format(subscription.startDate),
                            ),
                          ),
                          SizedBox(width: AppDimensions.marginMedium),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.timelapse,
                              label: 'Duration',
                              value: '${subscription.durationDays} days',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppDimensions.marginMedium),

                      // Price and persons info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.currency_rupee,
                              label: 'Price',
                              value: '₹${subscription.subscriptionPrice}',
                            ),
                          ),
                          SizedBox(width: AppDimensions.marginMedium),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.people,
                              label: 'Persons',
                              value: '${subscription.noOfPersons}',
                            ),
                          ),
                        ],
                      ),

                      if (!needsPayment) ...[
                        SizedBox(height: AppDimensions.marginMedium),

                        // Progress bar and days remaining (only for paid subscriptions)
                        _buildProgressSection(),
                      ],

                      SizedBox(height: AppDimensions.marginMedium),

                      // Address info
                      _buildAddressInfo(),
                    ],
                  ),
                ),

                // Footer with action hint
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginMedium,
                    vertical: AppDimensions.marginSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(AppDimensions.borderRadiusLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Tap to view details',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: onPayPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text(
        'Pay Now',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppDimensions.marginSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final daysRemaining = _calculateDaysRemaining();
    final progress = _calculateProgress();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              daysRemaining > 0
                  ? '$daysRemaining ${daysRemaining == 1 ? "day" : "days"} left'
                  : 'Completed',
              style: TextStyle(
                fontSize: 11,
                color:
                    daysRemaining > 0
                        ? AppColors.success
                        : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.marginSmall),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            daysRemaining > 0 ? AppColors.success : AppColors.textSecondary,
          ),
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
        SizedBox(width: AppDimensions.marginSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Address',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '${subscription.address.city}, ${subscription.address.state}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getStatusText() {
    if (subscription.isPaused) return 'Paused';

    switch (subscription.status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.pending:
        return subscription.paymentStatus == PaymentStatus.pending
            ? 'Payment Pending'
            : 'Pending Activation';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
    }
  }

  IconData _getStatusIcon() {
    if (subscription.isPaused) return Icons.pause_circle;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        return Icons.check_circle;
      case SubscriptionStatus.pending:
        return subscription.paymentStatus == PaymentStatus.pending
            ? Icons.payment
            : Icons.hourglass_top;
      case SubscriptionStatus.paused:
        return Icons.pause_circle;
      case SubscriptionStatus.cancelled:
        return Icons.cancel;
      case SubscriptionStatus.expired:
        return Icons.event_busy;
    }
  }

  Color _getStatusColor() {
    if (subscription.isPaused) return AppColors.warning;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        return AppColors.success;
      case SubscriptionStatus.pending:
        return subscription.paymentStatus == PaymentStatus.pending
            ? AppColors.error
            : AppColors.warning;
      case SubscriptionStatus.paused:
        return AppColors.warning;
      case SubscriptionStatus.cancelled:
        return AppColors.error;
      case SubscriptionStatus.expired:
        return AppColors.textSecondary;
    }
  }

  String _getShortId() {
    return subscription.id.length > 8
        ? subscription.id.substring(0, 8)
        : subscription.id;
  }

  int _calculateDaysRemaining() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );

    // If subscription hasn't started yet
    if (today.isBefore(startDate)) {
      return subscription.durationDays;
    }

    // Calculate end date (inclusive)
    final endDate = startDate.add(
      Duration(days: subscription.durationDays - 1),
    );

    // If subscription has ended
    if (today.isAfter(endDate)) {
      return 0;
    }

    // Return days remaining including today
    return endDate.difference(today).inDays + 1;
  }

  double _calculateProgress() {
    final daysRemaining = _calculateDaysRemaining();
    if (subscription.durationDays <= 0) return 0.0;

    final daysCompleted = subscription.durationDays - daysRemaining;
    return (daysCompleted / subscription.durationDays).clamp(0.0, 1.0);
  }
}
