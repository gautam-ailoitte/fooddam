// lib/src/presentation/screens/orders/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
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
      // Use the simplified cubit method to load all orders at once
      await context.read<OrdersCubit>().loadAllOrders();
    } catch (e) {
      _logger.e('Error loading orders: $e', tag: 'OrdersScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Your Meals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(12.0),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No meal data available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAllOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Load Meals'),
                  ),
                ],
              ),
            );
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
          const SizedBox(height: 20),
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
          _buildUpcomingHeader(state),
          UpcomingOrdersWidget(ordersByDate: state.upcomingOrdersByDate),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // History Tab Content
  Widget _buildHistoryTab(OrdersDataLoaded state) {
    if (!state.hasPastOrders) {
      return _buildEmptyState('No order history found');
    }

    // Remove the SingleChildScrollView and directly use PastOrdersWidget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHistoryHeader(state),
        Expanded(
          // Add this to give the ListView space to scroll
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
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Meals Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You have ${state.todayOrders.length} meal${state.todayOrders.length > 1 ? 's' : ''} scheduled for today.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          if (state.hasUpcomingDeliveries) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.upcomingDeliveriesToday.length} upcoming ${state.upcomingDeliveriesToday.length > 1 ? 'deliveries' : 'delivery'}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.upcomingDeliveriesToday.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(
                            'Next: ${state.upcomingDeliveriesToday.first.meal.name} (${state.upcomingDeliveriesToday.first.mealType})',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
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
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Upcoming Meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'You have ${state.totalUpcomingCount} upcoming meal${state.totalUpcomingCount > 1 ? 's' : ''} scheduled.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
              SizedBox(width: 4),
              Text(
                'Meals scheduled across ${state.upcomingOrdersByDate.length} day${state.upcomingOrdersByDate.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (state.totalUpcomingCount > 0) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meal Delivery Schedule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Breakfast: 7:30-8:30 AM\nLunch: 12:00-1:00 PM\nDinner: 7:00-8:00 PM',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
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

  // History Tab Header
  Widget _buildHistoryHeader(OrdersDataLoaded state) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Past Orders',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You have enjoyed ${state.totalPastOrderCount} meal${state.totalPastOrderCount > 1 ? 's' : ''} so far.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Orders from the past ${state.pastOrdersByDate.length} day${state.pastOrdersByDate.length > 1 ? 's' : ''}',
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

  // Helper to build empty state with custom message
  Widget _buildEmptyState(String message) {
    return Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAllOrders,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
