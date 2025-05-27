// lib/src/presentation/widgets/active_plan_card.dart
import 'package:flutter/material.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';

class ActivePlanCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const ActivePlanCard({super.key, required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getStatusColors(),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSubscriptionTitle(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getDateRange(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Subscription details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.restaurant_menu,
                        label: 'Total Meals',
                        value: subscription.totalSlots.toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.people,
                        label: 'Persons',
                        value: subscription.noOfPersons.toString(),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.calendar_today,
                        label: 'Days Left',
                        value: subscription.remainingDays.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom row with price and action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '₹${subscription.subscriptionPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Action button
                    if (_shouldShowPayButton())
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Pay Now',
                          style: TextStyle(
                            color: _getStatusColors().first,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Get status colors based on new API structure
  List<Color> _getStatusColors() {
    // Check if subscription is active and payment is completed
    if (subscription.status == SubscriptionStatus.active &&
        _isPaymentCompleted()) {
      return [Colors.green.shade400, Colors.green.shade600];
    }
    // Check if subscription is pending (could be payment pending or starting soon)
    else if (subscription.status == SubscriptionStatus.pending) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    }
    // Check if subscription is paused
    else if (subscription.status == SubscriptionStatus.paused ||
        subscription.isPaused) {
      return [Colors.blue.shade400, Colors.blue.shade600];
    }
    // Check if subscription is cancelled
    else if (subscription.status == SubscriptionStatus.cancelled) {
      return [Colors.red.shade400, Colors.red.shade600];
    }
    // Check if subscription is expired
    else if (subscription.status == SubscriptionStatus.expired) {
      return [Colors.grey.shade400, Colors.grey.shade600];
    }

    // Default fallback
    return [Colors.grey.shade400, Colors.grey.shade600];
  }

  /// Get status text based on new API structure
  String _getStatusText() {
    // Active subscription with completed payment
    if (subscription.status == SubscriptionStatus.active &&
        _isPaymentCompleted()) {
      return 'Active';
    }
    // Pending subscription - check payment status
    else if (subscription.status == SubscriptionStatus.pending) {
      if (!_isPaymentCompleted()) {
        return 'Payment Pending';
      } else {
        return 'Starting Soon';
      }
    }
    // Paused subscription
    else if (subscription.status == SubscriptionStatus.paused ||
        subscription.isPaused) {
      return 'Paused';
    }
    // Cancelled subscription
    else if (subscription.status == SubscriptionStatus.cancelled) {
      return 'Cancelled';
    }
    // Expired subscription
    else if (subscription.status == SubscriptionStatus.expired) {
      return 'Expired';
    }

    return 'Unknown';
  }

  /// Get subscription title based on new API structure
  String _getSubscriptionTitle() {
    // Try to get cloud kitchen name from new nested structure
    if (subscription.cloudKitchen != null &&
        subscription.cloudKitchen!.isNotEmpty) {
      return subscription.cloudKitchen!;
    }

    // Fallback to duration-based title
    return '${subscription.durationDays} Day Plan';
  }

  /// Check if payment is completed based on new API structure
  bool _isPaymentCompleted() {
    // Check the subscription's payment status
    return subscription.paymentStatus == PaymentStatus.paid;
  }

  /// Check if pay button should be shown
  bool _shouldShowPayButton() {
    return subscription.status == SubscriptionStatus.pending &&
        !_isPaymentCompleted();
  }

  String _getDateRange() {
    final startDate = subscription.startDate;
    final endDate = subscription.endDate ?? subscription.calculatedEndDate;

    if (endDate != null) {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
    return 'Started ${_formatDate(startDate)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
