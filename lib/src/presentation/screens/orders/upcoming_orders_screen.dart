// lib/src/presentation/screens/orders/upcoming_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/error_display_wideget.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_cubit.dart';
import 'package:foodam/src/presentation/cubits/orders/orders_state.dart';
import 'package:foodam/src/presentation/widgets/upcoming_orders_widget.dart';

class UpcomingOrdersScreen extends StatefulWidget {
  const UpcomingOrdersScreen({super.key});

  @override
  State<UpcomingOrdersScreen> createState() => _UpcomingOrdersScreenState();
}

class _UpcomingOrdersScreenState extends State<UpcomingOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _loadUpcomingOrders();
  }

  void _loadUpcomingOrders() {
    context.read<OrdersCubit>().loadUpcomingOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Meals'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadUpcomingOrders),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadUpcomingOrders();
          await Future.delayed(Duration(milliseconds: 300));
        },
        child: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return AppLoading(message: 'Loading upcoming meals...');
            } else if (state is OrdersError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: _loadUpcomingOrders,
              );
            } else if (state is UpcomingOrdersLoaded) {
              return _buildOrdersContent(state);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildOrdersContent(UpcomingOrdersLoaded state) {
    if (!state.hasUpcomingOrders) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state),
          UpcomingOrdersWidget(ordersByDate: state.ordersByDate),
        ],
      ),
    );
  }

  Widget _buildHeader(UpcomingOrdersLoaded state) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Meals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You have ${state.totalOrderCount} upcoming meal${state.totalOrderCount > 1 ? 's' : ''} scheduled.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
              SizedBox(width: 4),
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
                Icons.event_available_outlined,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                'No upcoming meals',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
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
}
