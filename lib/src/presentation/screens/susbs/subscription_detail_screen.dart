// lib/src/presentation/screens/susbs/subscription_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/widgets/subscription_scrren_widget.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load subscription details with smart caching
    _loadSubscriptionDetails(false);
  }

  // Load subscription details with an option to force refresh
  void _loadSubscriptionDetails(bool forceRefresh) {
    context.read<SubscriptionCubit>().loadSubscriptionDetails(
      widget.subscription.id,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            // If subscription was cancelled, go back
            if (state.action == 'cancel') {
              Navigator.pop(context);
            }
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is SubscriptionActionInProgress) {
            return _buildLoadingState(
              message: 'Processing ${state.action} request...',
            );
          } else if (state is SubscriptionLoaded) {
            // Get the subscription from state if available, otherwise use the widget parameter
            final Subscription subscription =
                state.selectedSubscription ?? widget.subscription;
            final int daysRemaining =
                state.daysRemaining ?? _calculateDaysRemaining(subscription);

            return _buildDetailContent(subscription, daysRemaining);
          } else if (state is SubscriptionLoading) {
            // Show loading with the initial subscription as fallback
            return Stack(
              children: [
                _buildDetailContent(
                  widget.subscription,
                  _calculateDaysRemaining(widget.subscription),
                ),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Fallback to using the subscription passed to the widget
            return _buildDetailContent(
              widget.subscription,
              _calculateDaysRemaining(widget.subscription),
            );
          }
        },
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

    // Generate end date based on start date and duration
    final endDate = subscription.startDate.add(
      Duration(days: subscription.durationDays),
    );

    return CustomScrollView(
      slivers: [
        // Animated app bar
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
                  // Gradient overlay for better text readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _loadSubscriptionDetails(true),
              tooltip: 'Refresh',
            ),
          ],
        ),

        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subscription overview card
                _buildOverviewCard(subscription, daysRemaining),
                SizedBox(height: 16),

                // Actions card - pause, resume, cancel
                _buildActionCard(subscription),
                SizedBox(height: 16),

                // Meal calendar card
                _buildMealCalendarCard(subscription),
                SizedBox(height: 16),

                // Delivery address card
                _buildDeliveryAddressCard(subscription),

                // Delivery instructions if available
                if (subscription.instructions != null &&
                    subscription.instructions!.isNotEmpty)
                  _buildInstructionsCard(subscription.instructions!),

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
      margin: EdgeInsets.zero,
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

            // Start date
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: DateFormat('MMMM d, yyyy').format(subscription.startDate),
            ),
            SizedBox(height: 12),

            // End date
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

            // Days remaining
            _buildDetailRow(
              icon: Icons.hourglass_bottom,
              label: 'Days Remaining',
              value: '$daysRemaining days',
              valueColor: daysRemaining > 0 ? null : AppColors.error,
            ),
            SizedBox(height: 12),

            // Total meals
            _buildDetailRow(
              icon: Icons.restaurant_menu,
              label: 'Total Meals',
              value: '${subscription.slots.length}',
            ),
            SizedBox(height: 12),

            // Subscription ID (shortened for display)
            _buildDetailRow(
              icon: Icons.tag,
              label: 'Subscription ID',
              value:
                  subscription.id.length > 8
                      ? '${subscription.id.substring(0, 8)}...'
                      : subscription.id,
            ),
            SizedBox(height: 12),

            // Payment status
            _buildDetailRow(
              icon: Icons.payment,
              label: 'Payment Status',
              value: _formatPaymentStatus(subscription.paymentStatus),
              valueColor: _getPaymentStatusColor(subscription.paymentStatus),
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),

            // Progress bar
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

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
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

            if (isPending) ...[
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
                onPressed: () => _showPauseDialog(context, subscription),
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
            ] else if (!isPending) ...[
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

  Widget _buildMealCalendarCard(Subscription subscription) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meal Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildEnhancedCalendarView(subscription),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedCalendarView(Subscription subscription) {
    // Group slots by day
    final Map<String, List<dynamic>> slotsByDay = {};
    for (final slot in subscription.slots) {
      if (!slotsByDay.containsKey(slot.day)) {
        slotsByDay[slot.day] = [];
      }
      slotsByDay[slot.day]!.add({
        'timing': slot.timing,
        'mealId': slot.mealId,
        'meal': slot.meal,
      });
    }

    // Sort days of the week in order
    final List<String> allDays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final List<String> sortedDays =
        allDays.where((day) => slotsByDay.keys.contains(day)).toList();

    return Column(
      children:
          sortedDays
              .map((day) => _buildDaySchedule(day, slotsByDay[day]!))
              .toList(),
    );
  }

  Widget _buildDaySchedule(String day, List<dynamic> slots) {
    // Sort slots by timing (breakfast, lunch, dinner)

    slots.sort((a, b) {
      final timingOrder = {'breakfast': 0, 'lunch': 1, 'dinner': 2};

      // Safely handle unknown meal timings
      final aIndex = timingOrder[a['timing'].toString().toLowerCase()] ?? 999;
      final bIndex = timingOrder[b['timing'].toString().toLowerCase()] ?? 999;

      return aIndex - bIndex;
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
          // Day header
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

          // Meal slots
          SizedBox(height: 8),
          ...slots.map((slot) => _buildMealSlot(slot)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealSlot(Map<String, dynamic> slot) {
    final String timing = slot['timing'];
    final meal = slot['meal'];
    final mealName = meal?.name ?? 'Selected Meal';

    // Determine icon and color based on meal timing
    IconData icon;
    Color color;
    switch (timing.toLowerCase()) {
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
                _formatMealType(timing),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                mealName,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(Subscription subscription) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 16),
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
                        subscription.address.street,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${subscription.address.city}, ${subscription.address.state} ${subscription.address.zipCode}',
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
      margin: EdgeInsets.only(top: 16, bottom: 16),
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

  void _showPauseDialog(BuildContext context, Subscription subscription) {
    showDialog(
      context: context,
      builder:
          (context) => PauseDialog(
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

  // Helper method to calculate days remaining
  int _calculateDaysRemaining(Subscription subscription) {
    final startDate = subscription.startDate;
    final endDate = startDate.add(Duration(days: subscription.durationDays));
    final now = DateTime.now();

    if (now.isAfter(endDate)) return 0;

    return endDate.difference(now).inDays;
  }
}
