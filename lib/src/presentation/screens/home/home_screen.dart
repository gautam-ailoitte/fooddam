// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
import 'package:foodam/src/domain/entities/susbcription_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_cubit.dart';
import 'package:foodam/src/presentation/cubits/today_meal_cubit/today_meal_cubit_state.dart';
import 'package:foodam/src/presentation/widgets/active_plan_card.dart';
import 'package:foodam/src/presentation/widgets/createPlanCta_widget.dart';
import 'package:foodam/src/presentation/widgets/today_meal_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load active subscriptions
    context.read<SubscriptionCubit>().loadActiveSubscriptions();

    // Load today's meals
    context.read<TodayMealCubit>().loadTodayMeals();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          _loadData();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom app bar
            _buildAppBar(),

            // Main content
            SliverToBoxAdapter(
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message
                        _buildWelcomeSection(authState.user),

                        // Today's meals section
                        _buildTodayMealsSection(),

                        // Active subscriptions section
                        _buildSubscriptionsSection(),

                        // Empty space at bottom to avoid FAB overlap
                        const SizedBox(height: 80),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'TiffinHub',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.restaurant,
                  size: 150,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.profileRoute);
          },
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(User user) {
    final greeting = _getGreeting();
    final displayName = user.firstName ?? 'there';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$greeting, ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                '!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome to TiffinHub, your personalized meal subscription app.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMealsSection() {
    return BlocBuilder<TodayMealCubit, TodayMealState>(
      builder: (context, state) {
        if (state is TodayMealLoading) {
          return _buildSectionLoading('Today\'s Meals');
        } else if (state is TodayMealError) {
          return _buildSectionError(
            'Today\'s Meals',
            state.message,
            () => context.read<TodayMealCubit>().loadTodayMeals(),
          );
        } else if (state is TodayMealLoaded) {
          if (!state.hasMealsToday) {
            return _buildEmptyMealsSection();
          }

          return _buildSectionCard(
            title: 'Today\'s Meals',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming meals
                  if (state.hasUpcomingDeliveries) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time,
                            color: AppColors.accent,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Upcoming Deliveries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Meal cards organized by type
                  TodayMealsWidget(
                    mealsByType: state.mealsByType,
                    currentMealPeriod: state.currentMealPeriod,
                  ),
                ],
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _buildEmptyMealsSection() {
    return _buildSectionCard(
      title: 'Today\'s Meals',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.restaurant, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No meals scheduled for today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Subscribe to a meal plan to get delicious meals delivered to your doorstep',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.packagesRoute);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Browse Meal Plans'),
            ),
          ],
        ),
      ),
    );
  }

  // lib/src/presentation/screens/home/home_screen.dart - _buildSubscriptionsSection method

Widget _buildSubscriptionsSection() {
  return BlocBuilder<SubscriptionCubit, SubscriptionState>(
    builder: (context, state) {
      if (state is SubscriptionLoading) {
        return _buildSectionLoading('Your Subscriptions');
      } else if (state is SubscriptionError) {
        return _buildSectionError(
          'Your Subscriptions',
          state.message,
          () => context.read<SubscriptionCubit>().loadActiveSubscriptions(),
        );
      } else if (state is SubscriptionLoaded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Subscriptions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (state.hasActiveSubscriptions ||
                      state.hasPausedSubscriptions)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.subscriptionsRoute,
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('See All'),
                    ),
                ],
              ),
            ),

            // Active subscriptions section
            if (state.hasActiveSubscriptions) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      state.activeSubscriptions
                          .map((subscription) {
                            return ActivePlanCard(
                              subscription: subscription,
                              onTap: () {
                                _navigateToSubscriptionDetail(context, subscription);
                              },
                            );
                          })
                          .take(2)
                          .toList(), // Limit to 2 for home screen
                ),
              ),
            ] else ...[
              // No active subscriptions - show CTA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CreatePlanCTA(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.packagesRoute);
                  },
                ),
              ),
            ],

            // Paused subscriptions section
            if (state.hasPausedSubscriptions) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Paused Subscriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      state.pausedSubscriptions
                          .map((subscription) {
                            return ActivePlanCard(
                              subscription: subscription,
                              onTap: () {
                                _navigateToSubscriptionDetail(context, subscription);
                              },
                            );
                          })
                          .take(1)
                          .toList(), // Limit to 1 for home screen
                ),
              ),
            ],
          ],
        );
      }

      return Container();
    },
  );
}

// Updated navigation method
void _navigateToSubscriptionDetail(BuildContext context, Subscription subscription) async {
  // Simply navigate to the detail screen with the subscription
  // There's no need for special refresh handling as our single state handles this
  await Navigator.of(context).pushNamed(
    AppRouter.subscriptionDetailRoute,
    arguments: subscription,
  );
  
  // No need to explicitly reload the subscriptions as that's handled by the cubit
}

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: EnhancedTheme.cardDecoration,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLoading(String title) {
    return _buildSectionCard(
      title: title,
      child: SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSectionError(
    String title,
    String message,
    VoidCallback onRetry,
  ) {
    return _buildSectionCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error loading data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.packagesRoute).then((_) {});
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Explore Plans',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
