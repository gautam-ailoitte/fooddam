// lib/src/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription_state.dart' as subscription_state;
import 'package:foodam/src/presentation/screens/auth/login_page.dart';
import 'package:foodam/src/presentation/screens/checkout/checkout_page.dart';
import 'package:foodam/src/presentation/screens/order/order_history_page.dart';
import 'package:foodam/src/presentation/screens/subscription/subscription_detail_page.dart';
import 'package:foodam/src/presentation/widgets/todays_meals_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    // Load subscription data
    context.read<SubscriptionCubit>().loadActiveSubscription();
    context.read<SubscriptionCubit>().loadDraftSubscription();
    
    // Load upcoming orders
    context.read<OrderManagementCubit>().loadUpcomingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.appTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // Navigate to profile page
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            _showLogoutConfirmation(context);
          },
        ),
      ],
      type: ScaffoldType.withAppBar,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveSubscriptionSection(),
              AppSpacing.vLg,
              _buildUpcomingDeliveriesSection(),
              AppSpacing.vLg,
              _buildTodayMealsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionSection() {
    return BlocBuilder<SubscriptionCubit, subscription_state.SubscriptionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AppCard(
            child: AppLoading(message: StringConstants.loadingSubscriptionData),
          );
        }

        if (state.status == subscription_state.SubscriptionStatus.error) {
          return AppCard(
            child: AppErrorWidget(
              message: state.errorMessage ?? 'Failed to load subscription data',
              onRetry: () => context.read<SubscriptionCubit>().loadActiveSubscription(),
              retryText: StringConstants.retry,
            ),
          );
        }

        if (state.hasActiveSubscription) {
          return _buildActiveSubscriptionCard(state.activeSubscription!);
        } else if (state.hasDraftSubscription) {
          return _buildDraftSubscriptionCard(state.draftSubscription!);
        } else {
          return _buildNoSubscriptionCard();
        }
      },
    );
  }

  Widget _buildActiveSubscriptionCard(Subscription subscription) {
    // Calculate days remaining
    final daysRemaining = subscription.endDate.difference(DateTime.now()).inDays;
    final isExpired = daysRemaining < 0;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: StringConstants.activePlan,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isExpired ? AppColors.error : AppColors.activeStatus,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isExpired ? 'Expired' : 'Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSm,
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _getSubscriptionTitle(subscription),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.vXs,
                Text(
                  'Duration: ${_getDurationText(subscription.duration)}',
                ),
                Text(
                  '${StringConstants.startDate} ${DateFormat('MMM dd, yyyy').format(subscription.startDate)}',
                ),
                Text(
                  '${StringConstants.endDate} ${DateFormat('MMM dd, yyyy').format(subscription.endDate)}',
                ),
                AppSpacing.vXs,
                if (!isExpired) ...[
                  Text(
                    '$daysRemaining ${StringConstants.daysRemaining}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ] else ...[
                  Text(
                    StringConstants.planExpired,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed(
                SubscriptionDetailsPage.routeName,
                arguments: subscription,
              );
            },
          ),
          AppSpacing.vSm,
          if (!isExpired) ...[
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Pause',
                    onPressed: () {
                      // Show pause dialog
                    },
                    buttonType: AppButtonType.outline,
                    buttonSize: AppButtonSize.small,
                    leadingIcon: Icons.pause,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: AppButton(
                    label: 'Renew',
                    onPressed: () {
                      // Navigate to renewal page
                    },
                    buttonType: AppButtonType.primary,
                    buttonSize: AppButtonSize.small,
                    leadingIcon: Icons.refresh,
                  ),
                ),
              ],
            ),
          ] else ...[
            AppButton(
              label: StringConstants.selectPlan,
              onPressed: () {
                Navigator.of(context).pushNamed(PlanSelectionPage.routeName);
              },
              buttonType: AppButtonType.primary,
              leadingIcon: Icons.add,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDraftSubscriptionCard(Subscription draftSubscription) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: StringConstants.draftPlanAvailable,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Draft',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          AppSpacing.vSm,
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _getSubscriptionTitle(draftSubscription),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(StringConstants.tapToResume),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to draft subscription customization
            },
          ),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: StringConstants.clear,
                  onPressed: () {
                    _showClearDraftConfirmation(context);
                  },
                  buttonType: AppButtonType.outline,
                  buttonSize: AppButtonSize.small,
                  leadingIcon: Icons.delete_outline,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: AppButton(
                  label: StringConstants.resumeDraft,
                  onPressed: () {
                    // Navigate to draft subscription customization
                  },
                  buttonType: AppButtonType.primary,
                  buttonSize: AppButtonSize.small,
                  leadingIcon: Icons.edit_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: StringConstants.noPlan,
          ),
          AppSpacing.vMd,
          Text(
            StringConstants.noSubscription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vMd,
          AppButton(
            label: StringConstants.selectPlan,
            onPressed: () {
              Navigator.of(context).pushNamed(PlanSelectionPage.routeName);
            },
            buttonType: AppButtonType.primary,
            leadingIcon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeliveriesSection() {
    return BlocBuilder<OrderManagementCubit, OrderManagementState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: 'Upcoming Deliveries',
              trailing: TextButton(
                onPressed: state.hasUpcomingOrders
                    ? () {
                        // Navigate to orders list
                      }
                    : null,
                child: const Text('See All'),
              ),
            ),
            AppSpacing.vSm,
            if (state.isLoading) ...[
              const Center(
                child: AppLoading(message: 'Loading deliveries...'),
              ),
            ] else if (state.status == OrderManagementStatus.error) ...[
              AppErrorWidget(
                message: state.errorMessage ?? 'Failed to load upcoming deliveries',
                onRetry: () => context.read<OrderManagementCubit>().loadUpcomingOrders(),
                retryText: StringConstants.retry,
              ),
            ] else if (state.hasUpcomingOrders) ...[
              _buildUpcomingOrdersList(state.upcomingOrders),
            ] else ...[
              const AppEmptyState(
                message: 'No upcoming deliveries',
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildUpcomingOrdersList(List<order_entity.Order> orders) {
    // Sort orders by delivery date
    final sortedOrders = List<order_entity.Order>.from(orders)
      ..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
    
    // Take only the next 3 orders
    final displayOrders = sortedOrders.take(3).toList();
    
    return Column(
      children: displayOrders.map((order) => _buildOrderCard(order)).toList(),
    );
  }

  Widget _buildOrderCard(order_entity.Order order) {
    final isToday = order.deliveryDate.day == DateTime.now().day &&
                     order.deliveryDate.month == DateTime.now().month &&
                     order.deliveryDate.year == DateTime.now().year;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isToday ? AppColors.accent : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('dd').format(order.deliveryDate),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                DateFormat('MMM').format(order.deliveryDate),
                style: TextStyle(
                  fontSize: 12,
                  color: isToday ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Text(
              'Order #${order.orderNumber.split('-').last}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            AppSpacing.hXs,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vXs,
            Text(
              'Delivery at ${DateFormat('hh:mm a').format(order.deliveryDate)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${order.meals.length} meals',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).pushNamed(
            OrderDetailsPage.routeName,
            arguments: order.id,
          );
        },
      ),
    );
  }

  Widget _buildTodayMealsSection() {
    return BlocBuilder<SubscriptionCubit, subscription_state.SubscriptionState>(
      builder: (context, state) {
        if (!state.hasActiveSubscription) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: StringConstants.todayMeals,
              trailing: TextButton(
                onPressed: () {
                  // Navigate to menu for today
                },
                child: Text(StringConstants.viewCompleteMenu),
              ),
            ),
            AppSpacing.vSm,
            const TodayMealsCard(),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StringConstants.logout),
        content: const Text(StringConstants.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(StringConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
            },
            child: Text(StringConstants.logout),
          ),
        ],
      ),
    );
  }

  void _showClearDraftConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StringConstants.clearDraft),
        content: const Text(StringConstants.clearDraftConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(StringConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<SubscriptionCubit>().clearDraftSubscription();
            },
            child: Text(StringConstants.clear),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionTitle(Subscription subscription) {
    final hasDietaryPreferences = subscription.mealPreferences.isNotEmpty;
    
    if (hasDietaryPreferences) {
      final firstPref = subscription.mealPreferences.first;
      if (firstPref.preferences.contains(DietaryPreference.vegetarian)) {
        return StringConstants.vegetarianPlan;
      } else if (firstPref.preferences.contains(DietaryPreference.nonVegetarian)) {
        return StringConstants.nonVegetarianPlan;
      }
    }
    
    return 'Meal Subscription';
  }

  String _getDurationText(SubscriptionDuration duration) {
    switch (duration) {
      case SubscriptionDuration.sevenDays:
        return '7 Days';
      case SubscriptionDuration.fourteenDays:
        return '14 Days';
      case SubscriptionDuration.twentyEightDays:
        return '28 Days';
      case SubscriptionDuration.monthly:
        return 'Monthly';
      case SubscriptionDuration.quarterly:
        return 'Quarterly';
      case SubscriptionDuration.halfYearly:
        return 'Half Yearly';
      case SubscriptionDuration.yearly:
        return 'Yearly';
      case SubscriptionDuration.days30:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getStatusColor(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return AppColors.warning;
      case order_entity.OrderStatus.confirmed:
        return AppColors.info;
      case order_entity.OrderStatus.preparing:
        return AppColors.accent;
      case order_entity.OrderStatus.ready:
        return AppColors.accent;
      case order_entity.OrderStatus.outForDelivery:
        return AppColors.accent;
      case order_entity.OrderStatus.delivered:
        return AppColors.success;
      case order_entity.OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return 'Pending';
      case order_entity.OrderStatus.confirmed:
        return 'Confirmed';
      case order_entity.OrderStatus.preparing:
        return 'Preparing';
      case order_entity.OrderStatus.ready:
        return 'Ready';
      case order_entity.OrderStatus.outForDelivery:
        return 'On the way';
      case order_entity.OrderStatus.delivered:
        return 'Delivered';
      case order_entity.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

