// lib/src/presentation/screens/subscription/active_plan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';
import 'package:foodam/src/presentation/screens/meal_selection_screen.dart';
import 'package:foodam/src/presentation/screens/thali_selection_screen.dart';
import 'package:foodam/src/presentation/widgets/delivery_schedule_card.dart';
import 'package:foodam/src/presentation/widgets/meal_preference_card.dart';
import 'package:intl/intl.dart';

class ActivePlanScreen extends StatefulWidget {
  final Subscription subscription;

  const ActivePlanScreen({
    super.key,
    required this.subscription,
  });

  @override
  State<ActivePlanScreen> createState() => _ActivePlanScreenState();
}

class _ActivePlanScreenState extends State<ActivePlanScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load upcoming orders
    context.read<OrderCubit>().getUpcomingOrders();
  }

  void _pauseSubscription() {
    // Show date picker for resume date
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        context
            .read<SubscriptionCubit>()
            .pauseSubscription(widget.subscription.id, selectedDate);
      }
    });
  }

  void _resumeSubscription() {
    context.read<SubscriptionCubit>().resumeSubscription(widget.subscription.id);
  }

  void _cancelSubscription() {
    TextEditingController reasonController = TextEditingController();
    
    AppDialogs.showCustomDialog(
      context: context,
      title: 'Cancel Subscription',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please tell us why you want to cancel:'),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your reason...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            final reason = reasonController.text.isNotEmpty
                ? reasonController.text
                : 'No reason provided';
            context
                .read<SubscriptionCubit>()
                .cancelSubscription(widget.subscription.id, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
          ),
          child: const Text('Confirm Cancellation'),
        ),
      ],
    );
  }

  void _navigateToMealSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MealSelectionScreen(),
      ),
    );
  }

  void _navigateToThaliSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ThaliSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.activePlan,
      body: BlocListener<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionPaused) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription paused successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is SubscriptionResumed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription resumed successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is SubscriptionCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Subscription cancelled successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Plan status card
              _buildPlanStatusCard(),
              AppSpacing.vLg,
              
              // Plan details
              AppSectionHeader(title: StringConstants.planDetailsTitle),
              AppSpacing.vSm,
              _buildPlanDetailsCard(),
              AppSpacing.vLg,
              
              // Meal preferences
              AppSectionHeader(
                title: 'Meal Preferences',
                trailing: TextButton(
                  onPressed: _navigateToThaliSelection,
                  child: const Text('Edit'),
                ),
              ),
              AppSpacing.vSm,
              ...(widget.subscription.mealPreferences
                  .map((pref) => _buildMealPreferenceCard(pref))
                  .toList()),
              AppSpacing.vLg,
              
              // Delivery schedule
              AppSectionHeader(title: 'Delivery Schedule'),
              AppSpacing.vSm,
              DeliveryScheduleCard(
                deliverySchedule: widget.subscription.deliverySchedule,
                address: widget.subscription.deliveryAddress,
              ),
              AppSpacing.vLg,
              
              // Upcoming orders
              AppSectionHeader(
                title: 'Upcoming Orders',
                trailing: TextButton(
                  onPressed: _navigateToMealSelection,
                  child: Text(StringConstants.viewCompleteMenu),
                ),
              ),
              AppSpacing.vSm,
              _buildUpcomingOrdersList(),
              AppSpacing.vLg,
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanStatusCard() {
    final now = DateTime.now();
    final daysRemaining = widget.subscription.endDate.difference(now).inDays;
    final isExpired = daysRemaining < 0;
    final isLastDay = daysRemaining == 0;
    
    return AppCard(
      backgroundColor: isExpired
          ? AppColors.error.withOpacity(0.1)
          : isLastDay
              ? AppColors.warning.withOpacity(0.1)
              : AppColors.success.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExpired
                  ? AppColors.error
                  : isLastDay
                      ? AppColors.warning
                      : AppColors.success,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired
                  ? Icons.error_outline
                  : isLastDay
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpired
                      ? StringConstants.planExpired
                      : isLastDay
                          ? StringConstants.lastDayPlan
                          : '$daysRemaining ${StringConstants.daysRemaining}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isExpired
                            ? AppColors.error
                            : isLastDay
                                ? AppColors.warning
                                : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${StringConstants.startDate} ${_formatDate(widget.subscription.startDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '${StringConstants.endDate} ${_formatDate(widget.subscription.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanDetailsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getPlanName(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${StringConstants.duration}: ${widget.subscription.durationInDays} days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            StringConstants.dailyBreakfastLunchDinner,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.subscription.isCustomized) ...[
            const SizedBox(height: 4),
            Text(
              'Customized Plan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.totalPrice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '₹${widget.subscription.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealPreferenceCard(MealPreference preference) {
    // Format meal type for display (capitalize first letter)
    final formattedMealType =
        preference.mealType.substring(0, 1).toUpperCase() +
        preference.mealType.substring(1);
    
    return MealPreferenceCard(
      title: formattedMealType,
      dietaryPreferences: preference.preferences,
      quantity: preference.quantity,
      onCustomize: () {
        // In active plan, we just view the preferences
      },
    );
  }

  Widget _buildUpcomingOrdersList() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: AppLoading()),
          );
        } else if (state is OrderError) {
          return AppErrorWidget(
            message: state.message,
            onRetry: _loadData,
            retryText: StringConstants.retry,
          );
        } else if (state is UpcomingOrdersLoaded) {
          if (state.orders.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No upcoming orders found'),
              ),
            );
          }
          
          return Column(
            children: state.orders.take(3).map((order) {
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
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
                        _buildOrderStatusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order #${order.orderNumber}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderStatusBadge(OrderStatus status) {
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

  Widget _buildActionButtons() {
    final isPaused = widget.subscription.status == SubscriptionStatus.paused;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPaused)
          AppButton(
            label: 'Resume Subscription',
            onPressed: _resumeSubscription,
            buttonType: AppButtonType.primary,
            buttonSize: AppButtonSize.medium,
          )
        else
          AppButton(
            label: 'Pause Subscription',
            onPressed: _pauseSubscription,
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.medium,
          ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Cancel Subscription',
          onPressed: _cancelSubscription,
          buttonType: AppButtonType.outline,
          buttonSize: AppButtonSize.medium,
          backgroundColor: AppColors.error.withOpacity(0.1),
          textColor: AppColors.error,
        ),
      ],
    );
  }

  String _getPlanName() {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = widget.subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = widget.subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.nonVegetarian),
    );
    
    if (hasVegetarianMeals && !hasNonVegetarianMeals) {
      return StringConstants.vegetarianPlan;
    } else if (hasNonVegetarianMeals) {
      return StringConstants.nonVegetarianPlan;
    } else {
      return 'Custom Plan';
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }
}