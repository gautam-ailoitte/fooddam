// lib/src/presentation/screens/subscription/subscription_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/core/widgets/primary_button.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_cubit.dart';
import 'package:foodam/src/presentation/cubits/subscription/subscription/subscription_details_state.dart';
import 'package:foodam/src/presentation/screens/susbs/subscription_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load subscriptions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionCubit>().loadSubscriptions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          // When navigating back, clear any detail state and return to list
          context.read<SubscriptionCubit>().returnToSubscriptionList();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('My Subscriptions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<SubscriptionCubit>().refreshSubscriptions();
              },
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white, // Selected tab text color
            unselectedLabelColor: Colors.white.withOpacity(
              0.7,
            ), // Unselected tab text color
            indicatorColor: Colors.white, // Tab indicator color
            indicatorWeight: 3.0,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Paused'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await context.read<SubscriptionCubit>().refreshSubscriptions();
          },
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return const AppLoading(
                  message: 'Loading your subscriptions...',
                );
              } else if (state is SubscriptionError) {
                return ErrorDisplayWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<SubscriptionCubit>().loadSubscriptions();
                  },
                );
              } else if (state is SubscriptionLoaded) {
                return _buildSubscriptionTabs(state);
              }
              return const Center(child: Text('No subscriptions found'));
            },
          ),
        ),
        // floatingActionButton: _buildFloatingActionButton(),
        floatingActionButton: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.packagesRoute);
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Explore Plans',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionTabs(SubscriptionLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Active subscriptions tab
        _buildSubscriptionList(
          context,
          state.getSortedSubscriptions(state.activeSubscriptions),
          'No active subscriptions',
          'Your active subscriptions will appear here',
          showPayButton: false,
        ),

        // Pending subscriptions tab
        _buildSubscriptionList(
          context,
          state.getSortedSubscriptions(state.pendingSubscriptions),
          'No pending subscriptions',
          'Your pending subscriptions will appear here',
          showPayButton: true,
        ),

        // Paused subscriptions tab
        _buildSubscriptionList(
          context,
          state.getSortedSubscriptions(state.pausedSubscriptions),
          'No paused subscriptions',
          'Your paused subscriptions will appear here',
          showPayButton: false,
        ),
      ],
    );
  }

  Widget _buildSubscriptionList(
    BuildContext context,
    List subscriptions,
    String emptyTitle,
    String emptySubtitle, {
    bool showPayButton = false,
  }) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(context, emptyTitle, emptySubtitle);
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return SubscriptionCard(
          subscription: subscription,
          showPayButton: showPayButton,
          onTap: () {
            Navigator.of(context)
                .pushNamed(
                  AppRouter.subscriptionDetailRoute,
                  arguments: subscription,
                )
                .then((_) {
                  // When returning from detail, use cached data
                  if (context.mounted) {
                    context
                        .read<SubscriptionCubit>()
                        .returnToSubscriptionList();
                  }
                });
          },
          onPayPressed:
              showPayButton ? () => _navigateToPayment(subscription) : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: AppDimensions.marginLarge),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginMedium),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.marginLarge),
              PrimaryButton(
                text: 'Explore Packages',
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.packagesRoute);
                },
                icon: Icons.search,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.packagesRoute).then((_) {
            // Refresh when returning from package screen
            if (context.mounted) {
              context.read<SubscriptionCubit>().refreshSubscriptions();
            }
          });
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Subscription',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _navigateToPayment(dynamic subscription) {
    // Navigate to subscription detail which will handle payment
    Navigator.of(context)
        .pushNamed(AppRouter.subscriptionDetailRoute, arguments: subscription)
        .then((_) {
          // Refresh list after returning from payment
          if (context.mounted) {
            context.read<SubscriptionCubit>().refreshSubscriptions();
          }
        });
  }
}
