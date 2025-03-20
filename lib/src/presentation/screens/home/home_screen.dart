// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/app_route_constant.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_empty_state.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/meal_order_entity.dart';
import 'package:foodam/src/presentation/cubits/active_subscription_cubit/active_subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/active_subscription_cubit/active_subscription_state.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';
import 'package:foodam/src/presentation/widgets/meal_order_card.dart';
import 'package:foodam/src/presentation/widgets/subscription_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<ActiveSubscriptionsCubit>().getActiveSubscriptions();
    context.read<TodayMealsCubit>().getTodayMeals();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hasBackButton: false,
      title: StringConstants.appTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
        ),
      ],
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
              // Active Subscriptions Section
              _buildActiveSubscriptionsSection(),
              
              AppSpacing.vLg,
              
              // Today's Meals Section
              _buildTodayMealsSection(),
              
              AppSpacing.vLg,
              
              // Create New Plan Button
              _buildCreateNewPlanButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: StringConstants.activePlan,
          trailing: BlocBuilder<ActiveSubscriptionsCubit, ActiveSubscriptionsState>(
            builder: (context, state) {
              if (state is ActiveSubscriptionsLoaded && state.activeSubscriptions.isNotEmpty) {
                return Text(
                  "${state.activeSubscriptions.length} ${StringConstants.activePlan}",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        
        BlocBuilder<ActiveSubscriptionsCubit, ActiveSubscriptionsState>(
          builder: (context, state) {
            if (state is ActiveSubscriptionsLoading) {
              return const AppLoading(message: StringConstants.loadingSubscription);
            } else if (state is ActiveSubscriptionsError) {
              return AppErrorWidget(
                message: state.message,
                retryText: StringConstants.retry,
                onRetry: _loadData,
              );
            } else if (state is ActiveSubscriptionsLoaded) {
              if (state.activeSubscriptions.isEmpty) {
                return AppEmptyState(
                  message: StringConstants.noPlan,
                  icon: Icons.food_bank_outlined,
                  actionLabel: StringConstants.selectPlan,
                  onAction: () {
                    Navigator.pushNamed(context, AppRoutes.planSelection);
                  },
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.activeSubscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = state.activeSubscriptions[index];
                  return SubscriptionCard(
                    subscription: subscription,
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.activePlan,
                        arguments: {'subscription': subscription},
                      );
                    },
                  );
                },
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTodayMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: StringConstants.todayMeals,
          trailing: BlocBuilder<TodayMealsCubit, TodayMealsState>(
            builder: (context, state) {
              if (state is TodayMealsLoaded && state.orders.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    // Navigate to detailed meals view
                  },
                  child: Text(StringConstants.viewCompleteMenu),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        
        BlocBuilder<TodayMealsCubit, TodayMealsState>(
          builder: (context, state) {
            if (state is TodayMealsLoading) {
              return const AppLoading(message: StringConstants.loadingSubscriptionData);
            } else if (state is TodayMealsError) {
              return AppErrorWidget(
                message: state.message,
                retryText: StringConstants.retry,
                onRetry: () => context.read<TodayMealsCubit>().getTodayMeals(),
              );
            } else if (state is TodayMealsLoaded) {
              if (state.orders.isEmpty) {
                return AppEmptyState(
                  message: StringConstants.noSubscription,
                  icon: Icons.restaurant_outlined,
                );
              }
              
              return Column(
                children: [
                  _buildMealTypeSection(context, 'Breakfast', state.ordersByType['Breakfast'] ?? []),
                  AppSpacing.vMd,
                  _buildMealTypeSection(context, 'Lunch', state.ordersByType['Lunch'] ?? []),
                  AppSpacing.vMd,
                  _buildMealTypeSection(context, 'Dinner', state.ordersByType['Dinner'] ?? []),
                ],
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(BuildContext context, String mealType, List<MealOrder> orders) {
    if (orders.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                _getMealTypeIcon(mealType),
                color: AppColors.textSecondary,
              ),
              AppSpacing.hMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _getMealTimeRange(mealType),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                StringConstants.noMealSelected,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Icon(
                _getMealTypeIcon(mealType),
                size: 20,
                color: AppColors.primary,
              ),
              AppSpacing.hSm,
              Text(
                mealType,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.hSm,
              Text(
                _getMealTimeRange(mealType),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return MealOrderCard(
              order: order,
              statusMessage: context.read<TodayMealsCubit>().getDeliveryStatusMessage(order),
            );
          },
        ),
      ],
    );
  }

  String _getMealTimeRange(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return StringConstants.breakfastTime;
      case 'Lunch':
        return StringConstants.lunchTime;
      case 'Dinner':
        return StringConstants.dinnerTime;
      default:
        return '';
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }

  Widget _buildCreateNewPlanButton() {
    return Center(
      child: AppButton(
        label: StringConstants.selectPlan,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.planSelection);
        },
        buttonType: AppButtonType.primary,
        buttonSize: AppButtonSize.large,
        isFullWidth: true,
        leadingIcon: Icons.add,
      ),
    );
  }
}