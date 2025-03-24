import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/theme/enhanced_app_them.dart';
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
  _EnhancedHomeScreenState createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<HomeScreen> {
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: CustomScrollView(
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
                        
                        // Empty space at bottom
                        SizedBox(height: 32),
                      ],
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
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
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
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
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary,
              ],
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
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {
            // Show notifications
          },
        ),
        IconButton(
          icon: Icon(Icons.person_outline),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.profileRoute);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(User user) {
    final greeting = _getGreeting();
    final displayName = user.firstName ?? 'there';
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$greeting, ',
                style: TextStyle(
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
              Text(
                '!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Welcome to TiffinHub, your personalized meal subscription app.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
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
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming meals
                  if (state.hasUpcomingDeliveries) ...[
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
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
                        SizedBox(width: 8),
                        Text(
                          'Upcoming Deliveries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.restaurant,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No meals scheduled for today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Subscribe to a meal plan to get delicious meals delivered to your doorstep',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.packagesRoute);
              },
              child: Text('Browse Meal Plans'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Your Subscriptions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              if (state.hasActiveSubscriptions) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: state.activeSubscriptions.map((subscription) {
                      return ActivePlanCard(
                        subscription: subscription,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.subscriptionDetailRoute,
                            arguments: subscription,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CreatePlanCTA(
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.packagesRoute);
                    },
                  ),
                ),
              ],
              
              // Paused subscriptions
              if (state.hasPausedSubscriptions) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Paused Subscriptions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: state.pausedSubscriptions.map((subscription) {
                      return ActivePlanCard(
                        subscription: subscription,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AppRouter.subscriptionDetailRoute,
                            arguments: subscription,
                          );
                        },
                      );
                    }).toList(),
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
      child: Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildSectionError(String title, String message, VoidCallback onRetry) {
    return _buildSectionCard(
      title: title,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, AppRouter.packagesRoute);
      },
      label: Text('Explore Plans'),
      icon: Icon(Icons.explore),
      backgroundColor: AppColors.primary,
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
