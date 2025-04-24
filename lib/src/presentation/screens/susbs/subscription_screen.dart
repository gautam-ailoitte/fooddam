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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Register this class as an observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadSubscriptions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is a good place to refresh data when returning to the screen
    ModalRoute? route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // If this is the current route, we might want to refresh data
      // We could check if we've navigated back from a subscription detail
      // But for simplicity, we'll just reload
      _loadSubscriptions();
    }
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadSubscriptions();
    }
  }

  Future<void> _loadSubscriptions() async {
    // Prevent multiple simultaneous loads
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<SubscriptionCubit>().loadActiveSubscriptions();
    } catch (e) {
      // Handle any errors if needed
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Subscriptions'),
        actions: [
          _isLoading
              ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
              : IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _loadSubscriptions,
                tooltip: 'Refresh',
              ),
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
          await _loadSubscriptions();
        },
        child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            // Listen for specific states that might indicate we need to refresh
            if (state is SubscriptionActionSuccess) {
              // A subscription was paused/resumed/cancelled, should refresh list
              _loadSubscriptions();
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading && _isLoading) {
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
          onTap: () async {
            // Navigate to detail screen and wait for result
            final result = await Navigator.of(context).pushNamed(
              AppRouter.subscriptionDetailRoute,
              arguments: subscription,
            );

            // When we come back, check if we need to refresh
            if (result == true || result == 'refresh') {
              _loadSubscriptions();
            }
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
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRouter.packagesRoute,
          );
          // Refresh when returning from package screen
          _loadSubscriptions();
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
