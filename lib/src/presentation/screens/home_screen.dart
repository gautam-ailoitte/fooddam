// lib/src/presentation/screens/home/home_screen.dart
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
import 'package:foodam/src/domain/entities/meal_entity.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:foodam/src/presentation/cubits/susbcription/subscription_cubit.dart';
import 'package:foodam/src/presentation/cubits/susbcription/susbcription_state.dart';
import 'package:foodam/src/presentation/screens/active_plan_screen.dart';
import 'package:foodam/src/presentation/screens/meal_selection_screen.dart';
import 'package:foodam/src/presentation/screens/order_details_screen.dart';
import 'package:foodam/src/presentation/screens/plan_selection_screen.dart';
import 'package:foodam/src/presentation/widgets/draft_plan_card.dart';
import 'package:foodam/src/presentation/widgets/upcoming_delivery_card.dart';
import 'package:foodam/src/presentation/widgets/user_profile_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load active subscription
    context.read<SubscriptionCubit>().getActiveSubscription();
    
    // Load draft subscription
    context.read<SubscriptionCubit>().getDraftSubscription();
    
    // Load upcoming orders
    context.read<OrderCubit>().getUpcomingOrders();
  }

  void _navigateToSelectPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PlanSelectionScreen()),
    );
  }

  void _navigateToPlanDetails(Subscription subscription) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivePlanScreen(subscription: subscription),
      ),
    );
  }

  void _navigateToOrderDetails(Order order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }

  void _navigateToMealSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MealSelectionScreen()),
    );
  }

  void _resumeDraftPlan(Subscription draftSubscription) {
    // Navigate to the appropriate screen based on where the user left off
    // This could be plan details, meal customization, etc.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivePlanScreen(subscription: draftSubscription),
      ),
    );
  }

  void _clearDraftPlan() {
    context.read<SubscriptionCubit>().clearDraftSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: StringConstants.appTitle,
      hasBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            // TODO: Navigate to profile screen
          },
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // User profile header
                  UserProfileHeader(user: authState.user),
                  AppSpacing.vLg,
                  
                  // Active subscription section
                  BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, state) {
                      if (state is SubscriptionLoading) {
                        return const AppLoading(
                          message: StringConstants.loadingSubscriptionData,
                        );
                      } else if (state is SubscriptionError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: _loadData,
                          retryText: StringConstants.retry,
                        );
                      } else if (state is ActiveSubscriptionLoaded) {
                        return _buildActiveSubscriptionCard(state.subscription);
                      } else if (state is NoActiveSubscription) {
                        return _buildNoSubscriptionCard();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  AppSpacing.vXl,
                  
                  // Draft plan section
                  BlocBuilder<SubscriptionCubit, SubscriptionState>(
                    builder: (context, state) {
                      if (state is DraftSubscriptionLoaded) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSectionHeader(
                              title: StringConstants.draftPlanAvailable,
                              trailing: TextButton(
                                onPressed: _clearDraftPlan,
                                child: Text(StringConstants.clear),
                              ),
                            ),
                            AppSpacing.vSm,
                            DraftPlanCard(
                              subscription: state.subscription,
                              onResume: () => _resumeDraftPlan(state.subscription),
                            ),
                            AppSpacing.vLg,
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Upcoming deliveries section
                  AppSectionHeader(
                    title: StringConstants.todayMeals,
                    trailing: TextButton(
                      onPressed: _navigateToMealSelection,
                      child: Text(StringConstants.viewCompleteMenu),
                    ),
                  ),
                  AppSpacing.vSm,
                  
                  BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      if (state is OrderLoading) {
                        return const AppLoading();
                      } else if (state is OrderError) {
                        return AppErrorWidget(
                          message: state.message,
                          onRetry: _loadData,
                          retryText: StringConstants.retry,
                        );
                      } else if (state is UpcomingOrdersLoaded) {
                        if (state.orders.isEmpty) {
                          return const AppEmptyState(
                            message: 'No upcoming deliveries',
                            icon: Icons.calendar_today,
                          );
                        }
                        
                        return Column(
                          children: state.orders.map((order) {
                            return UpcomingDeliveryCard(
                              order: order,
                              onTap: () => _navigateToOrderDetails(order),
                            );
                          }).toList(),
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            }
            
            // Show loading if not authenticated
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(Subscription subscription) {
    return AppCard(
      onTap: () => _navigateToPlanDetails(subscription),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.activePlan,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(),
          AppSpacing.vSm,
          // Plan details
          Text(
            _getPlanName(subscription),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.vXs,
          Text(
            '${StringConstants.duration}: ${subscription.durationInDays} days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vXs,
          Text(
            '${StringConstants.startDate} ${_formatDate(subscription.startDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vXs,
          Text(
            '${StringConstants.endDate} ${_formatDate(subscription.endDate)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppSpacing.vMd,
          AppButton(
            label: StringConstants.viewCompleteMenu,
            onPressed: _navigateToMealSelection,
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.small,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            StringConstants.noPlan,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.vMd,
          Text(
            StringConstants.noSubscription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          AppSpacing.vLg,
          AppButton(
            label: StringConstants.selectPlan,
            onPressed: _navigateToSelectPlan,
            buttonType: AppButtonType.primary,
            buttonSize: AppButtonSize.medium,
          ),
        ],
      ),
    );
  }

  String _getPlanName(Subscription subscription) {
    // This is a simplified implementation
    // In a real app, you'd have more information on the subscription
    bool hasVegetarianMeals = subscription.mealPreferences.any(
      (pref) => pref.preferences.contains(DietaryPreference.vegetarian),
    );
    
    bool hasNonVegetarianMeals = subscription.mealPreferences.any(
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
    return '${date.day}/${date.month}/${date.year}';
  }
}