// lib/features/subscriptions/screens/subscription_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/widgets/subscription_scrren_widget.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscription,
  });

  @override
  _SubscriptionDetailScreenState createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load the complete subscription details
    context.read<SubscriptionCubit>().loadSubscriptionDetails(widget.subscription.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<SubscriptionCubit>().loadSubscriptionDetails(widget.subscription.id),
          ),
        ],
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            
            // If subscription was cancelled, go back to the list
            if (state.action == 'cancel') {
              Navigator.pop(context);
            }
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionActionInProgress) {
            return AppLoading(
              message: state is SubscriptionActionInProgress
                  ? 'Processing ${state.action} request...'
                  : 'Loading subscription details...',
            );
          } else if (state is SubscriptionDetailLoaded) {
            final subscription = state.subscription;
            return _buildDetailContent(context, subscription, state.daysRemaining);
          } else {
            // Use the subscription passed to the screen while waiting for detailed data
            return _buildDetailContent(context, widget.subscription, 0);
          }
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Subscription subscription, int daysRemaining) {
    final bool isActive = subscription.status == SubscriptionStatus.active && !subscription.isPaused;
    final bool isPaused = subscription.isPaused || subscription.status == SubscriptionStatus.paused;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          SubscriptionStatusCard(
            subscription: subscription,
            daysRemaining: daysRemaining,
          ),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Action card
          SubscriptionActionCard(
            isActive: isActive,
            isPaused: isPaused,
            onPause: () => _showPauseDialog(context, subscription),
            onResume: () => _resumeSubscription(context, subscription),
            onCancel: () => _showCancelConfirmation(context, subscription),
          ),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Subscription details
          _buildSubscriptionDetails(context, subscription),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Calendar view of meals
          Text(
            'Your Meal Schedule',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppDimensions.marginMedium),
          CalendarView(subscription: subscription),
          SizedBox(height: AppDimensions.marginLarge),
          
          // Delivery address
          Text(
            'Delivery Address',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: AppDimensions.marginMedium),
          DeliveryAddressCard(address: subscription.address),
          
          // Special instructions if available
          if (subscription.instructions != null && subscription.instructions!.isNotEmpty) ...[
            SizedBox(height: AppDimensions.marginLarge),
            Text(
              'Delivery Instructions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.marginMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      subscription.instructions!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          SizedBox(height: AppDimensions.marginLarge * 2),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, Subscription subscription) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.marginMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppDimensions.marginMedium),
            
            _buildDetailRow(
              context,
              'Start Date',
              DateFormat('MMMM d, yyyy').format(subscription.startDate),
              Icons.calendar_today,
            ),
            Divider(),
            
            _buildDetailRow(
              context,
              'Subscription ID',
              subscription.id,
              Icons.numbers,
            ),
            Divider(),
            
            _buildDetailRow(
              context,
              'Payment Status',
              _getPaymentStatusText(subscription.paymentStatus),
              Icons.payment,
              valueColor: _getPaymentStatusColor(subscription.paymentStatus),
            ),
            Divider(),
            
            _buildDetailRow(
              context,
              'Total Meals',
              '${subscription.slots.length}',
              Icons.restaurant_menu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  void _showPauseDialog(BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => PauseDialog(
        onConfirm: (untilDate) {
          Navigator.pop(context);
          context.read<SubscriptionCubit>().pauseSubscription(
                subscription.id,
                untilDate,
              );
        },
      ),
    );
  }

  void _resumeSubscription(BuildContext context, Subscription subscription) {
    context.read<SubscriptionCubit>().resumeSubscription(subscription.id);
  }

  void _showCancelConfirmation(BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription'),
        content: Text('Are you sure you want to cancel this subscription? This action cannot be undone.'),
        actions: [
          TextButton(
            child: Text('No, Keep It'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<SubscriptionCubit>().cancelSubscription(subscription.id);
            },
          ),
        ],
      ),
    );
  }
}