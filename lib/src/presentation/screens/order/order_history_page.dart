// lib/src/presentation/pages/order/order_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetailsPage extends StatefulWidget {
  static const routeName = '/order-details';

  final String orderId;

  const OrderDetailsPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderManagementCubit>().getOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderManagementCubit, OrderManagementState>(
      listener: (context, state) {
        if (state.status == OrderManagementStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.selectedOrder == null) {
          return const Scaffold(
            body: Center(
              child: AppLoading(message: 'Loading order details...'),
            ),
          );
        }

        if (state.status == OrderManagementStatus.error && state.selectedOrder == null) {
          return Scaffold(
            body: Center(
              child: AppErrorWidget(
                message: state.errorMessage ?? 'Failed to load order details',
                onRetry: () {
                  context.read<OrderManagementCubit>().getOrderDetails(widget.orderId);
                },
                retryText: StringConstants.retry,
              ),
            ),
          );
        }

        final order = state.selectedOrder;
        if (order == null) {
          return Scaffold(
            body: Center(
              child: Text('Order not found'),
            ),
          );
        }

        return AppScaffold(
          title: 'Order #${order.orderNumber.split('-').last}',
          type: ScaffoldType.withAppBar,
          body: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderStatusCard(context, order),
                AppSpacing.vLg,
                _buildDeliveryDetailsCard(context, order),
                AppSpacing.vLg,
                _buildOrderItemsCard(context, order),
                AppSpacing.vLg,
                _buildOrderSummaryCard(context, order),
                AppSpacing.vLg,
                if (_canCancelOrder(order)) ...[
                  AppButton(
                    label: 'Cancel Order',
                    onPressed: () => _showCancelConfirmation(context, order),
                    buttonType: AppButtonType.secondary,
                    backgroundColor: AppColors.error,
                    leadingIcon: Icons.cancel_outlined,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderStatusCard(BuildContext context, order_entity.Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: 'Order Status',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(order.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          AppSpacing.vMd,
          _buildOrderTimeline(context, order),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline(BuildContext context, order_entity.Order order) {
    final statuses = [
      order_entity.OrderStatus.pending,
      order_entity.OrderStatus.confirmed,
      order_entity.OrderStatus.preparing,
      order_entity.OrderStatus.outForDelivery,
      order_entity.OrderStatus.delivered,
    ];

    // Determine current status index
    final currentIndex = statuses.indexOf(order.status);
    
    // If order is cancelled, show a special timeline
    if (order.status == order_entity.OrderStatus.cancelled) {
      return Column(
        children: [
          TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: true,
            isLast: true,
            indicatorStyle: IndicatorStyle(
              width: 20,
              color: AppColors.error,
              iconStyle: IconStyle(
                color: Colors.white,
                iconData: Icons.cancel_outlined,
              ),
            ),
            endChild: _buildTimelineChild(
              title: 'Order Cancelled',
              subtitle: 'Your order has been cancelled',
              time: order.updatedAt != null
                  ? DateFormat('dd MMM, hh:mm a').format(order.updatedAt!)
                  : 'N/A',
              isActive: true,
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isActive = index <= currentIndex;
        final isCompleted = index < currentIndex;
        
        return TimelineTile(
          alignment: TimelineAlign.start,
          isFirst: index == 0,
          isLast: index == statuses.length - 1,
          indicatorStyle: IndicatorStyle(
            width: 20,
            color: isActive ? _getStatusColor(status) : AppColors.textTertiary,
            iconStyle: IconStyle(
              color: Colors.white,
              iconData: isCompleted ? Icons.check : _getStatusIcon(status),
            ),
          ),
          beforeLineStyle: LineStyle(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
          ),
          afterLineStyle: LineStyle(
            color: index < currentIndex ? AppColors.primary : AppColors.textTertiary,
          ),
          endChild: _buildTimelineChild(
            title: _getStatusTitle(status),
            subtitle: _getStatusDescription(status),
            time: isActive
                ? (index == currentIndex
                    ? 'Current Status'
                    : DateFormat('dd MMM, hh:mm a').format(DateTime.now().subtract(Duration(hours: (statuses.length - index) * 2))))
                : 'Pending',
            isActive: isActive,
          ),
        );
      }),
    );
  }

  Widget _buildTimelineChild({
    required String title,
    required String subtitle,
    required String time,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
          AppSpacing.vXs,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.textSecondary : AppColors.textTertiary,
            ),
          ),
          AppSpacing.vXs,
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard(BuildContext context, order_entity.Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.vMd,
          _buildInfoRow(
            context,
            label: 'Delivery Date',
            value: DateFormat('EEEE, dd MMMM yyyy').format(order.deliveryDate),
            icon: Icons.calendar_today,
          ),
          AppSpacing.vSm,
          _buildInfoRow(
            context,
            label: 'Delivery Time',
            value: DateFormat('hh:mm a').format(order.deliveryDate),
            icon: Icons.access_time,
          ),
          AppSpacing.vSm,
          _buildInfoRow(
            context,
            label: 'Delivery Address',
            value: order.deliveryAddress.fullAddress,
            icon: Icons.location_on_outlined,
          ),
          if (order.deliveryInstructions != null && order.deliveryInstructions!.isNotEmpty) ...[
            AppSpacing.vSm,
            _buildInfoRow(
              context,
              label: 'Instructions',
              value: order.deliveryInstructions!,
              icon: Icons.info_outline,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, order_entity.Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.vMd,
          ...order.meals.map((meal) => _buildMealItem(context, meal)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, order_entity.OrderedMeal meal) {
    IconData icon;
    Color color;

    switch (meal.mealType.toLowerCase()) {
      case 'breakfast':
        icon = Icons.free_breakfast;
        color = Colors.orange;
        break;
      case 'lunch':
        icon = Icons.lunch_dining;
        color = Colors.green;
        break;
      case 'dinner':
        icon = Icons.dinner_dining;
        color = Colors.deepPurple;
        break;
      default:
        icon = Icons.restaurant;
        color = AppColors.primary;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        _getMealTypeText(meal.mealType),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        meal.dietPreference.capitalize(),
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      trailing: Text(
        'x${meal.quantity}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, order_entity.Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          AppSpacing.vMd,
          _buildInfoRow(
            context,
            label: 'Order Number',
            value: order.orderNumber,
            icon: Icons.confirmation_number_outlined,
          ),
          AppSpacing.vSm,
          _buildInfoRow(
            context,
            label: 'Order Date',
            value: DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
            icon: Icons.event_note_outlined,
          ),
          AppSpacing.vSm,
          _buildInfoRow(
            context,
            label: 'Payment Status',
            value: _getPaymentStatusText(order.paymentStatus),
            icon: Icons.payment,
            valueColor: _getPaymentStatusColor(order.paymentStatus),
          ),
          AppSpacing.vMd,
          const Divider(),
          AppSpacing.vSm,
          _buildPriceRow(
            context,
            label: StringConstants.total,
            value: '₹${order.totalAmount.toInt()}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, order_entity.Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(StringConstants.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<OrderManagementCubit>().cancelOrder(order.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  bool _canCancelOrder(order_entity.Order order) {
    // Can only cancel if order is in pending or confirmed state
    return order.status == order_entity.OrderStatus.pending ||
        order.status == order_entity.OrderStatus.confirmed;
  }

  Color _getStatusColor(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return AppColors.warning;
      case order_entity.OrderStatus.confirmed:
        return AppColors.info;
      case order_entity.OrderStatus.preparing:
        return AppColors.accent;
      case order_entity.OrderStatus.ready:
        return AppColors.accent;
      case order_entity.OrderStatus.outForDelivery:
        return AppColors.primary;
      case order_entity.OrderStatus.delivered:
        return AppColors.success;
      case order_entity.OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return 'Pending';
      case order_entity.OrderStatus.confirmed:
        return 'Confirmed';
      case order_entity.OrderStatus.preparing:
        return 'Preparing';
      case order_entity.OrderStatus.ready:
        return 'Ready';
      case order_entity.OrderStatus.outForDelivery:
        return 'On the way';
      case order_entity.OrderStatus.delivered:
        return 'Delivered';
      case order_entity.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusTitle(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return 'Order Placed';
      case order_entity.OrderStatus.confirmed:
        return 'Order Confirmed';
      case order_entity.OrderStatus.preparing:
        return 'Preparing Your Meal';
      case order_entity.OrderStatus.ready:
        return 'Ready for Delivery';
      case order_entity.OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case order_entity.OrderStatus.delivered:
        return 'Delivered';
      case order_entity.OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getStatusDescription(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return 'Your order has been received';
      case order_entity.OrderStatus.confirmed:
        return 'Your order has been confirmed';
      case order_entity.OrderStatus.preparing:
        return 'Our chefs are preparing your meal';
      case order_entity.OrderStatus.ready:
        return 'Your meal is packed and ready';
      case order_entity.OrderStatus.outForDelivery:
        return 'Your meal is on the way';
      case order_entity.OrderStatus.delivered:
        return 'Your meal has been delivered';
      case order_entity.OrderStatus.cancelled:
        return 'Your order has been cancelled';
    }
  }

  IconData _getStatusIcon(order_entity.OrderStatus status) {
    switch (status) {
      case order_entity.OrderStatus.pending:
        return Icons.watch_later_outlined;
      case order_entity.OrderStatus.confirmed:
        return Icons.thumb_up_outlined;
      case order_entity.OrderStatus.preparing:
        return Icons.restaurant_outlined;
      case order_entity.OrderStatus.ready:
        return Icons.inventory_2_outlined;
      case order_entity.OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case order_entity.OrderStatus.delivered:
        return Icons.check_circle_outline;
      case order_entity.OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  Color _getPaymentStatusColor(order_entity.PaymentStatus status) {
    switch (status) {
      case order_entity.PaymentStatus.pending:
        return AppColors.warning;
      case order_entity.PaymentStatus.paid:
        return AppColors.success;
      case order_entity.PaymentStatus.failed:
        return AppColors.error;
      case order_entity.PaymentStatus.refunded:
        return AppColors.info;
    }
  }

  String _getPaymentStatusText(order_entity.PaymentStatus status) {
    switch (status) {
      case order_entity.PaymentStatus.pending:
        return 'Payment Pending';
      case order_entity.PaymentStatus.paid:
        return 'Paid';
      case order_entity.PaymentStatus.failed:
        return 'Payment Failed';
      case order_entity.PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  String _getMealTypeText(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      default:
        return mealType;
    }
  }
}

// Extension to capitalize first letter of string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}