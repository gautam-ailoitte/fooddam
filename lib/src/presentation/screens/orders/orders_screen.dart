// lib/src/presentation/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/logger_service.dart';
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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final LoggerService _logger = LoggerService();
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _logger.d('Orders screen initialized', tag: 'OrdersScreen');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadAllOrders();
    }
  }

  @override
  void dispose() {
    _logger.d('Orders screen disposing', tag: 'OrdersScreen');
    _tabController.dispose();
    super.dispose();
  }

  // Load all orders data at once
  Future<void> _loadAllOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _logger.d('Loading all orders', tag: 'OrdersScreen');
      await context.read<OrdersCubit>().loadAllOrders();
    } catch (e) {
      _logger.e('Error loading orders: $e', tag: 'OrdersScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Your Meals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(AppDimensions.marginMedium),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllOrders,
              tooltip: 'Refresh',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorWeight: 3,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllOrders,
        color: AppColors.primary,
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            // Handle loading state
            if (state is OrdersLoading) {
              return const AppLoading(message: 'Loading your meals...');
            }

            // Handle error state
            if (state is OrdersError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadAllOrders,
              );
            }

            // Handle data loaded state
            if (state is OrdersDataLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  // Today Tab
                  _buildTodayTab(state),

                  // Upcoming Tab
                  _buildUpcomingTab(state),

                  // History Tab
                  _buildHistoryTab(state),
                ],
              );
            }

            // Initial or unknown state
            return _buildEmptyState('No meal data available', showButton: true);
          },
        ),
      ),
    );
  }

  // Today Tab Content
  Widget _buildTodayTab(OrdersDataLoaded state) {
    if (!state.hasTodayOrders) {
      return _buildEmptyState('No meals scheduled for today');
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
          SizedBox(height: AppDimensions.marginLarge),
        ],
      ),
    );
  }

  // Upcoming Tab Content
  Widget _buildUpcomingTab(OrdersDataLoaded state) {
    if (!state.hasUpcomingOrdersFuture) {
      return _buildEmptyState('No upcoming meals scheduled');
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // _buildUpcomingHeader(state),
          UpcomingOrdersWidget(ordersByDate: state.upcomingOrdersByDate),
          SizedBox(height: AppDimensions.marginLarge),
        ],
      ),
    );
  }

  // History Tab Content
  Widget _buildHistoryTab(OrdersDataLoaded state) {
    if (!state.hasPastOrders) {
      return _buildEmptyState('No order history found');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // _buildHistoryHeader(state),
        Expanded(
          child: PastOrdersWidget(
            ordersByDate: state.pastOrdersByDate,
            onLoadMore: () => context.read<OrdersCubit>().loadMorePastOrders(),
            isLoadingMore: state.isLoadingMore,
            canLoadMore: state.canLoadMore,
          ),
        ),
      ],
    );
  }

  // Today Tab Header
  Widget _buildTodayHeader(OrdersDataLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Meals Today',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            'You have ${state.todayOrders.length} meal${state.todayOrders.length > 1 ? 's' : ''} scheduled for today.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (state.hasUpcomingDeliveries) ...[
            SizedBox(height: AppDimensions.marginMedium),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.marginMedium,
                vertical: AppDimensions.marginSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bike,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppDimensions.marginSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.upcomingDeliveriesToday.length} upcoming ${state.upcomingDeliveriesToday.length > 1 ? 'deliveries' : 'delivery'}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.upcomingDeliveriesToday.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(
                            'Next: ${state.upcomingDeliveriesToday.first.dish?.name ?? 'Unknown'} (${state.upcomingDeliveriesToday.first.mealType})',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Upcoming Tab Header
  Widget _buildUpcomingHeader(OrdersDataLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available, color: AppColors.accent),
              SizedBox(width: AppDimensions.marginSmall),
              Text(
                'Upcoming Meals',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.marginMedium),
          Text(
            'You have ${state.totalUpcomingCount} upcoming meal${state.totalUpcomingCount > 1 ? 's' : ''} scheduled.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
              SizedBox(width: 4),
              Text(
                'Meals scheduled across ${state.upcomingOrdersByDate.length} day${state.upcomingOrdersByDate.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  // History Tab Header
  Widget _buildHistoryHeader(OrdersDataLoaded state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.marginMedium),
      margin: EdgeInsets.all(AppDimensions.marginMedium),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Orders',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Text(
            'You have enjoyed ${state.totalPastOrderCount} meal${state.totalPastOrderCount > 1 ? 's' : ''} so far.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.marginSmall),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Orders from the past ${state.pastOrdersByDate.length} day${state.pastOrdersByDate.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  // Helper to build empty state with custom message
  Widget _buildEmptyState(String message, {bool showButton = false}) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.marginLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: AppDimensions.marginMedium),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (showButton) ...[
                SizedBox(height: AppDimensions.marginLarge),
                ElevatedButton.icon(
                  onPressed: _loadAllOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Meals'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.marginMedium,
                      vertical: AppDimensions.marginMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
