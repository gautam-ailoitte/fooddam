// lib/src/presentation/screens/subscription/subscription_detail_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/domain/entities/payment_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/payment/razor_pay_cubit/razor_pay_cubit/razor_pay_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:intl/intl.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  bool _isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    // Load fresh subscription details on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionCubit>().loadSubscriptionDetail(
        widget.subscription.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // Return to cached subscription list when going back
          context.read<SubscriptionCubit>().returnToSubscriptionList();
        }
      },
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
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

                  // Show success dialog and navigate to home
                  AppDialogs.showSuccessDialog(
                    context: context,
                    title: 'Payment Successful',
                    message:
                        'Your subscription has been activated successfully.',
                    buttonText: 'Go to Home',
                    onPressed: () {
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
                    message: "Payment failed. Returning to Home Screen",
                    buttonText: 'Home',
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.mainRoute,
                        (route) => false,
                      );
                    },
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
                  if (state is SubscriptionLoading) {
                    return const AppLoading(
                      message: 'Loading subscription details...',
                    );
                  } else if (state is SubscriptionError) {
                    return ErrorDisplayWidget(
                      message: state.message,
                      onRetry: () {
                        context
                            .read<SubscriptionCubit>()
                            .loadSubscriptionDetail(widget.subscription.id);
                      },
                    );
                  } else if (state is SubscriptionDetailLoaded) {
                    return _buildDetailContent(state.subscription, state);
                  }

                  // Fallback to widget subscription if state not loaded yet
                  return _buildDetailContent(widget.subscription, null);
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
      ),
    );
  }

  Widget _buildDetailContent(
    Subscription subscription,
    SubscriptionDetailLoaded? detailState,
  ) {
    final bool isActive =
        subscription.status == SubscriptionStatus.active &&
        !subscription.isPaused;
    final bool isPaused =
        subscription.isPaused ||
        subscription.status == SubscriptionStatus.paused;
    final bool isPending = subscription.status == SubscriptionStatus.pending;
    final bool needsPayment =
        isPending && subscription.paymentStatus == PaymentStatus.pending;

    return CustomScrollView(
      slivers: [
        // App bar with gradient
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
                    offset: const Offset(0, 1),
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
                      needsPayment
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
                      needsPayment
                          ? Icons.payment
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusText(subscription),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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
                // Overview card
                _buildOverviewCard(subscription, detailState),
                SizedBox(height: AppDimensions.marginMedium),

                // Action card
                _buildActionCard(subscription),
                SizedBox(height: AppDimensions.marginMedium),

                // Meal schedule card (if has weeks data)
                if (detailState?.hasWeeks == true) ...[
                  _buildMealScheduleCard(subscription, detailState!),
                  SizedBox(height: AppDimensions.marginMedium),
                ],

                // Delivery address card
                _buildDeliveryAddressCard(subscription),

                // Instructions card (if has instructions)
                if (subscription.instructions != null &&
                    subscription.instructions!.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.marginMedium),
                  _buildInstructionsCard(subscription.instructions!),
                ],

                SizedBox(height: AppDimensions.marginLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    Subscription subscription,
    SubscriptionDetailLoaded? detailState,
  ) {
    final daysRemaining =
        detailState?.daysRemaining ?? _calculateDaysRemaining(subscription);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subscription Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: DateFormat('MMMM d, yyyy').format(subscription.startDate),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.event,
              label: 'Duration',
              value: '${subscription.durationDays} days',
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.hourglass_bottom,
              label: 'Days Remaining',
              value:
                  daysRemaining > 0
                      ? '$daysRemaining ${daysRemaining == 1 ? "day" : "days"}'
                      : 'Completed',
              valueColor: daysRemaining > 0 ? null : AppColors.error,
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.restaurant_menu,
              label: 'Total Meals',
              value: '${subscription.totalSlots}',
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.people,
              label: 'Persons',
              value: '${subscription.noOfPersons}',
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.currency_rupee,
              label: 'Total Price',
              value: '₹${subscription.subscriptionPrice}',
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.payment,
              label: 'Payment Status',
              value: _formatPaymentStatus(subscription.paymentStatus),
              valueColor: _getPaymentStatusColor(subscription.paymentStatus),
            ),

            // Progress section
            if (subscription.paymentStatus == PaymentStatus.paid) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildProgressSection(subscription, daysRemaining),
            ],
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
        const SizedBox(width: 12),
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

  Widget _buildProgressSection(Subscription subscription, int daysRemaining) {
    final progress = _calculateProgress(subscription);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subscription Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
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
        const SizedBox(height: 8),
        Text(
          _getProgressText(subscription, daysRemaining),
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
    final bool needsPayment =
        isPending && subscription.paymentStatus == PaymentStatus.pending;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (needsPayment) ...[
              _buildActionButton(
                label: 'Pay Now - ₹${subscription.subscriptionPrice}',
                icon: Icons.payment,
                color: AppColors.primary,
                onPressed: () => _processPayment(subscription),
              ),
              const SizedBox(height: 16),
              _buildInfoMessage(
                icon: Icons.info_outline,
                title: 'Payment Required',
                message:
                    'Complete payment to activate your subscription and start receiving meals.',
                color: Colors.amber,
              ),
            ] else if (isPending) ...[
              _buildInfoMessage(
                icon: Icons.hourglass_top,
                title: 'Activation Pending',
                message:
                    'Your subscription is being prepared. You\'ll receive meals starting from the scheduled date.',
                color: Colors.blue,
              ),
            ] else if (isActive) ...[
              _buildActionButton(
                label: 'Pause Subscription',
                icon: Icons.pause,
                color: AppColors.warning,
                onPressed: () => _showPauseConfirmation(subscription),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Cancel Subscription',
                icon: Icons.cancel,
                color: AppColors.error,
                onPressed: () => _showCancelConfirmation(subscription),
              ),
            ] else if (isPaused) ...[
              _buildActionButton(
                label: 'Resume Subscription',
                icon: Icons.play_arrow,
                color: AppColors.success,
                onPressed: () => _resumeSubscription(subscription),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Cancel Subscription',
                icon: Icons.cancel,
                color: AppColors.error,
                onPressed: () => _showCancelConfirmation(subscription),
              ),
            ] else ...[
              _buildInfoMessage(
                icon: Icons.info_outline,
                title: 'No Actions Available',
                message: 'This subscription cannot be modified at this time.',
                color: AppColors.textSecondary,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color),
        ),
      ),
    );
  }

  Widget _buildInfoMessage({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: color.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealScheduleCard(
    Subscription subscription,
    SubscriptionDetailLoaded detailState,
  ) {
    // Extract today's and upcoming meals from subscription data
    final todayMeals = _getTodayMealsFromSubscription(subscription);
    final upcomingMeals = _getUpcomingMealsFromSubscription(subscription);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meal Schedule',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to detailed meal schedule screen
                    Navigator.pushNamed(
                      context,
                      AppRouter.subscriptionMealScheduleRoute,
                      arguments: subscription,
                    );
                  },
                  icon: const Icon(Icons.calendar_view_week, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show today's meals if available
            if (todayMeals.isNotEmpty) ...[
              const Text(
                'Today\'s Meals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...todayMeals
                  .take(3)
                  .map((meal) => _buildMealItem(meal, isToday: true))
                  .toList(),
              const SizedBox(height: 16),
            ],

            // Show upcoming meals preview
            if (upcomingMeals.isNotEmpty) ...[
              const Text(
                'Upcoming Meals',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...upcomingMeals
                  .take(3)
                  .map((meal) => _buildMealItem(meal, isToday: false))
                  .toList(),
            ],

            if (todayMeals.isEmpty && upcomingMeals.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Meal schedule will be available once your subscription is activated.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Add these helper methods to extract meals from subscription data:

  List<dynamic> _getTodayMealsFromSubscription(Subscription subscription) {
    final today = DateTime.now();
    final todayMeals = <dynamic>[];

    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return todayMeals;
    }

    for (final week in subscription.weeks!) {
      for (final slot in week.slots) {
        if (slot.date != null) {
          final slotDate = slot.date!;
          if (slotDate.year == today.year &&
              slotDate.month == today.month &&
              slotDate.day == today.day &&
              slot.meal != null) {
            todayMeals.add(slot);
          }
        }
      }
    }

    // Sort by meal timing order (breakfast, lunch, dinner)
    todayMeals.sort((a, b) {
      return _getMealTimeOrder(
        a.timing ?? '',
      ).compareTo(_getMealTimeOrder(b.timing ?? ''));
    });

    return todayMeals;
  }

  List<dynamic> _getUpcomingMealsFromSubscription(Subscription subscription) {
    final now = DateTime.now();
    final upcomingMeals = <dynamic>[];

    if (subscription.weeks == null || subscription.weeks!.isEmpty) {
      return upcomingMeals;
    }

    for (final week in subscription.weeks!) {
      for (final slot in week.slots) {
        if (slot.date != null && slot.date!.isAfter(now) && slot.meal != null) {
          upcomingMeals.add(slot);
        }
      }
    }

    // Sort by date and then by meal timing
    upcomingMeals.sort((a, b) {
      final dateComparison = a.date!.compareTo(b.date!);
      if (dateComparison != 0) {
        return dateComparison;
      }
      // If same date, sort by meal time
      return _getMealTimeOrder(
        a.timing ?? '',
      ).compareTo(_getMealTimeOrder(b.timing ?? ''));
    });

    return upcomingMeals;
  }

  int _getMealTimeOrder(String timing) {
    switch (timing.toLowerCase()) {
      case 'breakfast':
        return 0;
      case 'lunch':
        return 1;
      case 'dinner':
        return 2;
      default:
        return 3;
    }
  }

  Widget _buildMealItem(dynamic slot, {bool isToday = false}) {
    // Helper methods (add these to the class if not already present)
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

    String _formatTiming(String timing) {
      return timing.substring(0, 1).toUpperCase() +
          timing.substring(1).toLowerCase();
    }

    String _getMealTimeRange(String timing) {
      switch (timing.toLowerCase()) {
        case 'breakfast':
          return '7:00 AM - 10:00 AM';
        case 'lunch':
          return '12:00 PM - 3:00 PM';
        case 'dinner':
          return '7:00 PM - 10:00 PM';
        default:
          return '';
      }
    }

    // Extract meal data from slot
    final meal = slot.meal;
    final timing = slot.timing ?? '';
    final date = slot.date;

    // Get meal type color and icon
    final mealColor = _getMealTypeColor(timing);
    final mealIcon = _getMealTypeIcon(timing);

    // Format date
    String formattedDate = '';
    String formattedTime = _getMealTimeRange(timing);
    if (date != null) {
      if (isToday) {
        formattedDate = 'Today';
      } else {
        formattedDate = DateFormat('MMM d').format(date);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap:
              meal != null
                  ? () {
                    // Navigate to meal detail screen
                    Navigator.pushNamed(
                      context,
                      AppRouter.mealDetailRoute,
                      arguments: {
                        'meal': meal,
                        'timing': timing,
                        'date': date ?? DateTime.now(),
                        'subscription': widget.subscription,
                      },
                    );
                  }
                  : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isToday ? mealColor.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isToday ? mealColor.withOpacity(0.3) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        isToday
                            ? mealColor.withOpacity(0.15)
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    mealIcon,
                    size: 16,
                    color: isToday ? mealColor : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal name and timing
                      Row(
                        children: [
                          Text(
                            _formatTiming(timing),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color:
                                  isToday ? mealColor : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Meal name or no meal message
                      if (meal != null) ...[
                        Text(
                          meal.name ?? 'Meal',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isToday
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        Text(
                          'No meal planned',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      // Date
                      if (formattedDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              isToday ? Icons.today : Icons.calendar_today,
                              size: 10,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow icon if meal exists
                if (meal != null) ...[
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isToday ? mealColor : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressCard(Subscription subscription) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: EnhancedTheme.cardDecoration,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.address.street,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscription.address.city}, ${subscription.address.state} ${subscription.address.zipCode}',
                        style: const TextStyle(color: AppColors.textSecondary),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    instructions,
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _processPayment(Subscription subscription) {
    if (_isPaymentProcessing) return;

    AppDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Payment',
      message:
          'Do you want to proceed with payment of ₹${subscription.subscriptionPrice}?',
      confirmText: 'Pay Now',
      cancelText: 'Cancel',
    ).then((confirmed) {
      if (confirmed == true) {
        final paymentCubit = context.read<RazorpayPaymentCubit>();
        paymentCubit.processPaymentForSubscription(
          subscription.id,
          PaymentMethod.upi,
        );
      }
    });
  }

  void _showPauseConfirmation(Subscription subscription) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pause Subscription'),
            content: const Text(
              'Are you sure you want to pause this subscription? Your meals will be temporarily stopped.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
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

  void _resumeSubscription(Subscription subscription) {
    context.read<SubscriptionCubit>().resumeSubscription(subscription.id);
  }

  void _showCancelConfirmation(Subscription subscription) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Subscription'),
            content: const Text(
              'Are you sure you want to cancel this subscription? This action cannot be undone.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                child: const Text('No, Keep It'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
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

  // Helper methods
  String _getStatusText(Subscription subscription) {
    if (subscription.isPaused) return 'PAUSED';

    switch (subscription.status) {
      case SubscriptionStatus.pending:
        return subscription.paymentStatus == PaymentStatus.pending
            ? 'PAYMENT PENDING'
            : 'PENDING';
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

  int _calculateDaysRemaining(Subscription subscription) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );

    if (today.isBefore(startDate)) {
      return subscription.durationDays;
    }

    final endDate = startDate.add(
      Duration(days: subscription.durationDays - 1),
    );
    if (today.isAfter(endDate)) {
      return 0;
    }

    return endDate.difference(today).inDays + 1;
  }

  double _calculateProgress(Subscription subscription) {
    if (subscription.durationDays <= 0) return 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );

    if (today.isBefore(startDate)) {
      return 0.0;
    }

    final daysCompleted = today.difference(startDate).inDays + 1;
    return min(daysCompleted / subscription.durationDays, 1.0);
  }

  String _getProgressText(Subscription subscription, int daysRemaining) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      subscription.startDate.year,
      subscription.startDate.month,
      subscription.startDate.day,
    );

    if (today.isBefore(startDate)) {
      final daysUntilStart = startDate.difference(today).inDays;
      return 'Starting in ${daysUntilStart} ${daysUntilStart == 1 ? 'day' : 'days'}';
    }

    final endDate = startDate.add(
      Duration(days: subscription.durationDays - 1),
    );
    if (today.isAfter(endDate)) {
      return 'Completed ${subscription.durationDays} days';
    }

    final daysCompleted = today.difference(startDate).inDays + 1;
    return '${daysCompleted} ${daysCompleted == 1 ? 'day' : 'days'} completed out of ${subscription.durationDays} days';
  }
}
