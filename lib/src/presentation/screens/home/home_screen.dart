// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';
import 'package:foodam/src/presentation/widgets/active_plan_card.dart';
import 'package:foodam/src/presentation/widgets/createPlanCta_widget.dart';
import 'package:foodam/src/presentation/widgets/today_meal_widget.dart';
import 'package:foodam/src/presentation/widgets/welcomde_wideget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    context.read<SubscriptionCubit>().loadActiveSubscriptions();
    context.read<TodayMealCubit>().loadTodayMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foodam'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
            // Wait for a brief moment to ensure the refresh indicator is shown
            await Future.delayed(Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section with user info
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return WelcomeWidget(user: state.user);
                    }
                    return SizedBox.shrink();
                  },
                ),
                
                // Active subscription section
                BlocBuilder<SubscriptionCubit, SubscriptionState>(
                  builder: (context, state) {
                    if (state is SubscriptionLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDimensions.marginLarge),
                        child: AppLoading(message: 'Loading your plans...'),
                      );
                    } else if (state is SubscriptionError) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDimensions.marginLarge),
                        child: ErrorDisplayWidget(
                          message: state.message,
                          onRetry: () => context.read<SubscriptionCubit>().loadActiveSubscriptions(),
                        ),
                      );
                    } else if (state is SubscriptionLoaded) {
                      if (state.hasActiveSubscriptions) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppDimensions.marginMedium),
                              child: Text(
                                'Your Active Plan',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: state.activeSubscriptions.length,
                              padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginMedium),
                              itemBuilder: (context, index) {
                                final subscription = state.activeSubscriptions[index];
                                return ActivePlanCard(
                                  subscription: subscription,
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      AppRouter.subscriptionDetailRoute,
                                      arguments: subscription,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      } else {
                        return CreatePlanCTA(
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.packagesRoute);
                          },
                        );
                      }
                    }
                    return SizedBox.shrink();
                  },
                ),
                
                SizedBox(height: AppDimensions.marginMedium),
                
                // Today's meals section
                BlocBuilder<TodayMealCubit, TodayMealState>(
                  builder: (context, state) {
                    if (state is TodayMealLoading) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDimensions.marginLarge),
                        child: AppLoading(message: 'Loading today\'s meals...'),
                      );
                    } else if (state is TodayMealError) {
                      return Padding(
                        padding: const EdgeInsets.all(AppDimensions.marginLarge),
                        child: ErrorDisplayWidget(
                          message: state.message,
                          onRetry: () => context.read<TodayMealCubit>().loadTodayMeals(),
                        ),
                      );
                    } else if (state is TodayMealLoaded) {
                      if (state.hasMealsToday) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppDimensions.marginMedium),
                              child: Text(
                                'Today\'s Meals',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            TodayMealsWidget(
                              mealsByType: state.mealsByType,
                              currentMealPeriod: state.currentMealPeriod,
                            ),
                          ],
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(AppDimensions.marginLarge),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimensions.marginLarge),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.restaurant_outlined,
                                    size: 48,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(height: AppDimensions.marginMedium),
                                  Text(
                                    'No meals scheduled for today',
                                    style: Theme.of(context).textTheme.titleLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: AppDimensions.marginSmall),
                                  Text(
                                    'Subscribe to a package to start receiving delicious meals',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }
                    return SizedBox.shrink();
                  },
                ),
                
                SizedBox(height: AppDimensions.marginMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}