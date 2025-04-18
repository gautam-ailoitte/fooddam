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
  @override
  void initState() {
    super.initState();
    _loadTodayOrders();
  }

  void _loadTodayOrders() {
    context.read<OrdersCubit>().loadTodayOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Meals'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadTodayOrders),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTodayOrders();
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return AppLoading(message: 'Loading today\'s meals...');
            } else if (state is OrdersError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadTodayOrders,
              );
            } else if (state is TodayOrdersLoaded) {
              return _buildOrdersContent(state);
            }
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
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_bike, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
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
            ],
          ),
        ),
      ),
    );
  }
}
