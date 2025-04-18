// lib/src/presentation/screens/orders/today_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
import 'package:foodam/src/presentation/widgets/todays_order_widget.dart';

class TodayOrdersScreen extends StatefulWidget {
  const TodayOrdersScreen({super.key});

  @override
  State<TodayOrdersScreen> createState() => _TodayOrdersScreenState();
}

class _TodayOrdersScreenState extends State<TodayOrdersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodayOrders();
  }

  Future<void> _loadTodayOrders() async {
    setState(() {
      _isLoading = true;
    });

    await context.read<OrdersCubit>().loadTodayOrders();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Meals'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon:
                _isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTodayOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTodayOrders();
        },
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            // Extract data from state to prevent UI errors if state changes
            final bool isLoading = state is OrdersLoading;
            final String? errorMessage =
                state is OrdersError ? state.message : null;
            final bool hasOrders =
                state is TodayOrdersLoaded && state.hasOrdersToday;

            // Handle loading state
            if (isLoading) {
              return AppLoading(message: 'Loading today\'s meals...');
            }

            // Handle error state
            if (errorMessage != null) {
              return ErrorDisplayWidget(
                message: errorMessage,
                onRetry: _loadTodayOrders,
              );
            }

            // Handle data states
            if (state is TodayOrdersLoaded) {
              return _buildOrdersContent(state);
            }

            // Fallback/initial state
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildOrdersContent(TodayOrdersLoaded state) {
    if (!state.hasOrdersToday) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state),
          TodayOrdersWidget(
            ordersByType: state.ordersByType,
            currentMealPeriod: state.currentMealPeriod,
          ),
          // Add some bottom padding
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(TodayOrdersLoaded state) {
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
            'You have ${state.orders.length} meal${state.orders.length > 1 ? 's' : ''} scheduled for today.',
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
                          '${state.upcomingDeliveries.length} upcoming ${state.upcomingDeliveries.length > 1 ? 'deliveries' : 'delivery'}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.upcomingDeliveries.isNotEmpty) ...[
                          SizedBox(height: 2),
                          Text(
                            'Next: ${state.upcomingDeliveries.first.meal.name} (${state.upcomingDeliveries.first.mealType})',
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

  Widget _buildEmptyState() {
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
                'No meals scheduled for today',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Check your upcoming meals or add a new subscription to get started.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadTodayOrders,
                icon: Icon(Icons.refresh),
                label: Text('Check Again'),
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
