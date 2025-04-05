// lib/features/subscriptions/screens/subscriptions_screen.dart
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
import 'package:foodam/src/presentation/widgets/susbcription_card.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  _SubscriptionsScreenState createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSubscriptions() {
    context.read<SubscriptionCubit>().loadActiveSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Subscriptions'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadSubscriptions),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Paused'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSubscriptions();
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return AppLoading(message: 'Loading your subscriptions...');
            } else if (state is SubscriptionError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadSubscriptions,
              );
            } else if (state is SubscriptionLoaded) {
              return _buildSubscriptionTabs(state);
            }
            return Center(child: Text('No subscriptions found'));
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSubscriptionTabs(SubscriptionLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        // Active subscriptions tab
        _buildSubscriptionList(
          context,
          state.activeSubscriptions,
          'No active subscriptions',
          'Your active subscriptions will appear here',
        ),

        // Pending subscriptions tab
        _buildSubscriptionList(
          context,
          state.pendingSubscriptions,
          'No pending subscriptions',
          'Your pending subscriptions will appear here',
        ),

        // Paused subscriptions tab
        _buildSubscriptionList(
          context,
          state.pausedSubscriptions,
          'No paused subscriptions',
          'Your paused subscriptions will appear here',
        ),
      ],
    );
  }

  Widget _buildSubscriptionList(
    BuildContext context,
    List subscriptions,
    String emptyTitle,
    String emptySubtitle,
  ) {
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
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRouter.subscriptionDetailRoute,
              arguments: subscription,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
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
            // Only refresh subscriptions if we're on the subscription screen
            _loadSubscriptions();
          });
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Subscription',
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
}
