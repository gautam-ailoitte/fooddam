import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/meal_slot_entity.dart';
import '../../widgets/meal_grid.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  bool _isPaymentProcessing = false;
  bool _isCompactView = false;

  @override
  void initState() {
    super.initState();
    // Load subscription details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionCubit>().loadSubscriptionDetails(
        widget.subscription.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Subscription Cubit Listener
          BlocListener<SubscriptionCubit, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionActionSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));

                // Reload details after action
                context.read<SubscriptionCubit>().loadSubscriptionDetails(
                  widget.subscription.id,
                );
              } else if (state is SubscriptionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
          // Razorpay Payment Listener
          BlocListener<RazorpayPaymentCubit, RazorpayPaymentState>(
            listener: (context, state) {
              if (state is RazorpayPaymentLoading) {
                setState(() {
                  _isPaymentProcessing = true;
                });
              } else if (state is RazorpayPaymentSuccessWithId) {
                setState(() {
                  _isPaymentProcessing = false;
                });

                // Show success dialog
                AppDialogs.showSuccessDialog(
                  context: context,
                  title: 'Payment Successful',
                  message: 'Your subscription has been activated successfully.',
                  buttonText: 'Go to Home',
                  onPressed: () {
                    // Refresh active subscriptions
                    context.read<SubscriptionCubit>().loadActiveSubscriptions();

                    // Navigate to home screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.mainRoute,
                      (route) => false,
                    );
                  },
                );
              } else if (state is RazorpayPaymentError) {
                setState(() {
                  _isPaymentProcessing = false;
                });

                AppDialogs.showAlertDialog(
                  context: context,
                  title: 'Payment Failed',
                  message: "Unexpected Error. Returning to HomeScreen",
                  buttonText: 'Home',
                  onPressed: () {
                    // Refresh active subscriptions
                    context.read<SubscriptionCubit>().loadActiveSubscriptions();
                    // navigate to main screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.mainRoute,
                      (route) => false,
                    );
                  },
                );
              } else if (state is RazorpayExternalWallet) {
                // Just show a message that external wallet was selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Processing payment with ${state.walletName}...',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // Main content
            BlocBuilder<SubscriptionCubit, SubscriptionState>(
              builder: (context, state) {
                if (state is SubscriptionActionInProgress) {
                  return _buildLoadingState(
                    message: 'Processing ${state.action} request...',
                  );
                }

                // Get the subscription data - either from state or widget
                final Subscription displaySubscription =
                    (state is SubscriptionLoaded &&
                            state.selectedSubscription != null)
                        ? state.selectedSubscription!
                        : widget.subscription;

                final int daysRemaining =
                    (state is SubscriptionLoaded)
                        ? (state.daysRemaining ??
                            _calculateDaysRemaining(displaySubscription))
                        : _calculateDaysRemaining(displaySubscription);

                return _buildDetailContent(displaySubscription, daysRemaining);
              },
            ),

            // Payment loading overlay
            if (_isPaymentProcessing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState({required String message}) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Details'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(message, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(Subscription subscription, int daysRemaining) {
    final bool isActive =
        subscription.status == SubscriptionStatus.active &&
        !subscription.isPaused;
    final bool isPaused =
        subscription.isPaused ||
        subscription.status == SubscriptionStatus.paused;
    final bool isPending = subscription.status == SubscriptionStatus.pending;

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Subscription Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isPending
                          ? [Colors.amber.withOpacity(0.8), Colors.amber]
                          : isPaused
                          ? [
                            AppColors.warning.withOpacity(0.8),
                            AppColors.warning,
                          ]
                          : isActive
                          ? [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary,
                          ]
                          : [Colors.grey.shade400, Colors.grey.shade600],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      isPending
                          ? Icons.hourglass_top
                          : isPaused
                          ? Icons.pause_circle
                          : Icons.restaurant,
                      size: 150,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getStatusText(subscription.status, isPaused),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.marginMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCard(subscription, daysRemaining),
                SizedBox(height: 16),
                _buildActionCard(subscription),
                SizedBox(height: 16),
                _buildMealScheduleCard(subscription),
                SizedBox(height: 16),
                _buildDeliveryAddressCard(subscription),
                if (subscription.instructions != null &&
                    subscription.instructions!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  _buildInstructionsCard(subscription.instructions!),
                ],
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(Subscription subscription, int daysRemaining) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: DateFormat('MMMM d, yyyy').format(subscription.startDate),
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.event,
              label: 'End Date',
              value: DateFormat('MMMM d, yyyy').format(
                subscription.startDate.add(
                  Duration(days: subscription.durationDays),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.hourglass_bottom,
              label: 'Days Remaining',
              value: '$daysRemaining days',
              valueColor: daysRemaining > 0 ? null : AppColors.error,
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.restaurant_menu,
              label: 'Total Meals',
              value: '${subscription.noOfSlots}',
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.tag,
              label: 'Subscription ID',
              value:
                  subscription.id.length > 8
                      ? '${subscription.id.substring(0, 8)}...'
                      : subscription.id,
            ),
            SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.payment,
              label: 'Payment Status',
              value: _formatPaymentStatus(subscription.paymentStatus),
              valueColor: _getPaymentStatusColor(subscription.paymentStatus),
            ),
            if (subscription.subscriptionPrice != null) ...[
              SizedBox(height: 12),
              _buildDetailRow(
                icon: Icons.currency_rupee,
                label: 'Subscription Price',
                value: '₹${subscription.subscriptionPrice}',
              ),
            ],
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Progress',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _calculateProgressValue(subscription, daysRemaining),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    subscription.status == SubscriptionStatus.pending
                        ? Colors.amber
                        : subscription.isPaused
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Text(
                  '${subscription.durationDays - daysRemaining} days completed out of ${subscription.durationDays} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActionCard(Subscription subscription) {
    final bool isActive =
        subscription.status == SubscriptionStatus.active &&
        !subscription.isPaused;
    final bool isPaused =
        subscription.isPaused ||
        subscription.status == SubscriptionStatus.paused;
    final bool isPending = subscription.status == SubscriptionStatus.pending;
    final bool isPaymentPending =
        subscription.paymentStatus == PaymentStatus.pending;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (isPending && isPaymentPending) ...[
              // Pay Now Button for pending payments
              _buildActionButton(
                label: 'Pay Now',
                icon: Icons.payment,
                color: AppColors.primary,
                onPressed: () => _processPayment(subscription),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top, size: 36, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'This subscription is pending payment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete the payment to activate your subscription',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else if (isPending) ...[
              Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_top, size: 36, color: Colors.amber),
                    SizedBox(height: 8),
                    Text(
                      'This subscription is pending activation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We\'re preparing your meals and will activate your subscription soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else if (isActive) ...[
              _buildActionButton(
                label: 'Pause Subscription',
                icon: Icons.pause,
                color: AppColors.warning,
                onPressed: () => _showPauseConfirmation(context, subscription),
              ),
              SizedBox(height: 12),
            ] else if (isPaused) ...[
              _buildActionButton(
                label: 'Resume Subscription',
                icon: Icons.play_arrow,
                color: AppColors.success,
                onPressed: () => _resumeSubscription(context, subscription),
              ),
              SizedBox(height: 12),
            ],
            if ((isActive || isPaused) && !isPending) ...[
              _buildActionButton(
                label: 'Cancel Subscription',
                icon: Icons.cancel,
                color: AppColors.error,
                onPressed: () => _showCancelConfirmation(context, subscription),
              ),
            ] else if (!isPending || !isPaymentPending) ...[
              Center(
                child: Text(
                  'No actions available for this subscription',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withOpacity(0.1),
        padding: EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size(double.infinity, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color),
        ),
      ),
    );
  }

  void _processPayment(Subscription subscription) {
    if (_isPaymentProcessing) return;

    // Show confirmation dialog first
    AppDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Payment',
      message:
          'Do you want to proceed with payment of ₹${subscription.subscriptionPrice ?? 0}?',
      confirmText: 'Pay Now',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed == true) {
        // Process payment using UPI as default payment method
        final paymentCubit = context.read<RazorpayPaymentCubit>();
        paymentCubit.processPaymentForSubscription(
          subscription.id,
          PaymentMethod.upi,
        );
      }
    });
  }

  Widget _buildMealScheduleCard(Subscription subscription) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meal Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Toggle button for compact/full view
                IconButton(
                  icon: Icon(
                    _isCompactView ? Icons.view_agenda : Icons.grid_view,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCompactView = !_isCompactView;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            MealGrid(
              mealSlots: subscription.slots,
              subscription: subscription,
              isCompact: _isCompactView,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList(Subscription subscription) {
    // Group meals by day
    final Map<String, List<MealSlot>> slotsByDay = {};

    for (final slot in subscription.slots) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add(slot);
    }

    // Sort days
    final List<String> days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    final sortedDays =
        days.where((day) => slotsByDay.containsKey(day)).toList();

    if (sortedDays.isEmpty) {
      return Center(
        child: Text(
          'No meals scheduled',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children:
          sortedDays.map((day) {
            final slots = slotsByDay[day]!;
            slots.sort((a, b) {
              final order = {'breakfast': 0, 'lunch': 1, 'dinner': 2};
              return (order[a.timing.toLowerCase()] ?? 3).compareTo(
                order[b.timing.toLowerCase()] ?? 3,
              );
            });

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatDay(day),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  ...slots.map((slot) => _buildMealSlot(slot)).toList(),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMealSlot(MealSlot slot) {
    IconData icon;
    Color color;
    switch (slot.timing.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = AppColors.accent;
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = Colors.purple;
        break;
      default:
        icon = Icons.restaurant;
        color = AppColors.primary;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatMealType(slot.timing),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                slot.meal?.name ?? 'Selected Meal',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(Subscription subscription) {
    if (subscription.address == null) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.address!.street,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${subscription.address!.city}, ${subscription.address!.state} ${subscription.address!.zipCode}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(String instructions) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(instructions, style: TextStyle(height: 1.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(SubscriptionStatus status, bool isPaused) {
    if (isPaused) return 'PAUSED';

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

  String _formatPaymentStatus(PaymentStatus status) {
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
        return Colors.blue;
    }
  }

  double _calculateProgressValue(Subscription subscription, int daysRemaining) {
    if (subscription.durationDays <= 0) return 0.0;
    final daysCompleted = subscription.durationDays - daysRemaining;
    return daysCompleted / subscription.durationDays;
  }

  void _showPauseConfirmation(BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pause Subscription'),
            content: Text(
              'Are you sure you want to pause this subscription? Your meals will be temporarily stopped.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text(
                  'Pause',
                  style: TextStyle(color: AppColors.warning),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SubscriptionCubit>().pauseSubscription(
                    subscription.id,
                  );
                },
              ),
            ],
          ),
    );
  }

  void _resumeSubscription(BuildContext context, Subscription subscription) {
    context.read<SubscriptionCubit>().resumeSubscription(subscription.id);
  }

  void _showCancelConfirmation(
    BuildContext context,
    Subscription subscription,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancel Subscription'),
            content: Text(
              'Are you sure you want to cancel this subscription? This action cannot be undone.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  context.read<SubscriptionCubit>().cancelSubscription(
                    subscription.id,
                  );
                  Navigator.pop(context); // Return to list
                },
              ),
            ],
          ),
    );
  }

  String _formatDay(String day) {
    if (day.isEmpty) return 'Day';
    return day.substring(0, 1).toUpperCase() + day.substring(1);
  }

  String _formatMealType(String mealType) {
    if (mealType.isEmpty) return 'Meal';
    return mealType.substring(0, 1).toUpperCase() + mealType.substring(1);
  }

  int _calculateDaysRemaining(Subscription subscription) {
    final startDate = subscription.startDate;
    final endDate = startDate.add(Duration(days: subscription.durationDays));
    final now = DateTime.now();

    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
