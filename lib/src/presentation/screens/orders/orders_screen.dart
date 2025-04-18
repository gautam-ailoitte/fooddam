// lib/src/presentation/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
import 'package:foodam/src/presentation/widgets/past_orders_widget.dart';
import 'package:foodam/src/presentation/widgets/todays_order_widget.dart';
import 'package:foodam/src/presentation/widgets/upcoming_orders_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load initial tab data
    _loadDataForCurrentTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadDataForCurrentTab();
    }
  }

  void _loadDataForCurrentTab() {
    final ordersCubit = context.read<OrdersCubit>();
    switch (_tabController.index) {
      case 0:
        ordersCubit.loadTodayOrders();
        break;
      case 1:
        ordersCubit.loadUpcomingOrders();
        break;
      case 2:
        ordersCubit.loadPastOrders();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Meals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayOrdersTab(),
          _buildUpcomingOrdersTab(),
          _buildOrderHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildTodayOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersCubit>().loadTodayOrders();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen:
            (previous, current) =>
                current is OrdersLoading ||
                current is OrdersError ||
                current is TodayOrdersLoaded,
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const AppLoading(message: 'Loading today\'s meals...');
          } else if (state is OrdersError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadTodayOrders(),
            );
          } else if (state is TodayOrdersLoaded) {
            return _buildTodayOrdersContent(state);
          }
          return _buildEmptyTodayState();
        },
      ),
    );
  }

  Widget _buildTodayOrdersContent(TodayOrdersLoaded state) {
    if (!state.hasOrdersToday) {
      return _buildEmptyTodayState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodayHeader(state),
          TodayOrdersWidget(
            ordersByType: state.ordersByType,
            currentMealPeriod: state.currentMealPeriod,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHeader(TodayOrdersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Meals Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have ${state.orders.length} meal${state.orders.length > 1 ? 's' : ''} scheduled for today.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          if (state.hasUpcomingDeliveries) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_bike, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${state.upcomingDeliveries.length} upcoming ${state.upcomingDeliveries.length > 1 ? 'deliveries' : 'delivery'}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyTodayState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No meals scheduled for today',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check your upcoming meals or add a new subscription to get started.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingOrdersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersCubit>().loadUpcomingOrders();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen:
            (previous, current) =>
                current is OrdersLoading ||
                current is OrdersError ||
                current is UpcomingOrdersLoaded,
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const AppLoading(message: 'Loading upcoming meals...');
          } else if (state is OrdersError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadUpcomingOrders(),
            );
          } else if (state is UpcomingOrdersLoaded) {
            return _buildUpcomingOrdersContent(state);
          }
          return _buildEmptyUpcomingState();
        },
      ),
    );
  }

  Widget _buildUpcomingOrdersContent(UpcomingOrdersLoaded state) {
    if (!state.hasUpcomingOrders) {
      return _buildEmptyUpcomingState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUpcomingHeader(state),
          UpcomingOrdersWidget(ordersByDate: state.ordersByDate),
        ],
      ),
    );
  }

  Widget _buildUpcomingHeader(UpcomingOrdersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Meals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have ${state.totalOrderCount} upcoming meal${state.totalOrderCount > 1 ? 's' : ''} scheduled.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
              const SizedBox(width: 4),
              Text(
                'Meals scheduled across ${state.ordersByDate.length} day${state.ordersByDate.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyUpcomingState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_available_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No upcoming meals',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new subscription to get delicious meals delivered to your doorstep.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersCubit>().loadPastOrders();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: BlocBuilder<OrdersCubit, OrdersState>(
        buildWhen:
            (previous, current) =>
                current is OrdersLoading ||
                current is OrdersError ||
                current is PastOrdersLoaded,
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const AppLoading(message: 'Loading order history...');
          } else if (state is OrdersError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadPastOrders(),
            );
          } else if (state is PastOrdersLoaded) {
            return _buildPastOrdersContent(state);
          }
          return _buildEmptyHistoryState();
        },
      ),
    );
  }

  Widget _buildPastOrdersContent(PastOrdersLoaded state) {
    if (!state.hasPastOrders) {
      return _buildEmptyHistoryState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryHeader(state),
          PastOrdersWidget(ordersByDate: state.ordersByDate),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(PastOrdersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Past Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have enjoyed ${state.totalOrderCount} meal${state.totalOrderCount > 1 ? 's' : ''} so far.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Orders from the past ${state.ordersByDate.length} day${state.ordersByDate.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No order history',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your past orders will appear here once you start enjoying our meals.',
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
