// lib/src/presentation/screens/order/order_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/app_colors.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/layout/app_scaffold.dart';
import 'package:foodam/core/layout/app_spacing.dart';
import 'package:foodam/core/service/dialog_service.dart';
import 'package:foodam/core/widgets/app_button.dart';
import 'package:foodam/core/widgets/app_card.dart';
import 'package:foodam/core/widgets/app_error_widget.dart';
import 'package:foodam/core/widgets/app_loading.dart';
import 'package:foodam/core/widgets/app_section_header.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/presentation/cubits/order/order_cubit.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    context.read<OrderCubit>().getOrderById(widget.orderId);
  }

  void _cancelOrder(Order order) {
    AppDialogs.showConfirmationDialog(
      context: context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order?',
      confirmText: 'Yes, Cancel',
      cancelText: 'No, Keep It',
      isDestructiveAction: true,
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<OrderCubit>().cancelOrder(order.id);
      }
    });
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    context.read<OrderCubit>().updateOrderStatus(order.id, newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Order Details',
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order cancelled successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order status updated successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: AppLoading());
          } else if (state is OrderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _loadOrderDetails,
              retryText: StringConstants.retry,
            );
          } else if (state is OrderLoaded || state is OrderStatusUpdated) {
            final Order order = state is OrderLoaded 
                ? state.order 
                : (state as OrderStatusUpdated).order;
                
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID and Status
                  _buildOrderHeaderCard(order),
                  AppSpacing.vLg,
                  
                  // Delivery details
                  AppSectionHeader(title: 'Delivery Details'),
                  AppSpacing.vSm,
                  _buildDeliveryDetailsCard(order),
                  AppSpacing.vLg,
                  
                  // Meal items
                  AppSectionHeader(title: 'Order Items'),
                  AppSpacing.vSm,
                  ...order.meals.map((meal) => _buildMealItemCard(meal)).toList(),
                  AppSpacing.vLg,
                  
                  // Payment details
                  AppSectionHeader(title: 'Payment Details'),
                  AppSpacing.vSm,
                  _buildPaymentDetailsCard(order),
                  AppSpacing.vLg,
                  
                  // Actions
                  _buildActionButtons(order),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderHeaderCard(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  AppSpacing.vXs,
                  Text(
                    _formatDateTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          AppSpacing.vMd,
          
          // Subscription info
          Row(
            children: [
              const Icon(
                Icons.receipt_long,
                size: 16,
                color: AppColors.textSecondary,
              ),
              AppSpacing.hXs,
              Text(
                'Subscription ID: ${order.subscriptionId}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsCard(Order order) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery date and time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              AppSpacing.hSm,
              Text(
                'Delivery Date: ${_formatDate(order.deliveryDate)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          AppSpacing.vSm,
          
          // Expected time slot (this would come from your backend)
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              AppSpacing.hSm,
              Text(
                'Expected Time: 8:00 AM - 11:00 AM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          AppSpacing.vMd,
          
          // Divider
          const Divider(),
          AppSpacing.vMd,
          
          // Delivery address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      order.deliveryAddress.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Delivery instructions (if any)
          if (order.deliveryInstructions != null &&
              order.deliveryInstructions!.isNotEmpty) ...[
            AppSpacing.vMd,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Instructions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        order.deliveryInstructions!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItemCard(OrderedMeal meal) {
    final mealType = meal.mealType.substring(0, 1).toUpperCase() + meal.mealType.substring(1);
    final dietPreference = meal.dietPreference.substring(0, 1).toUpperCase() + meal.dietPreference.substring(1);
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: meal.dietPreference.toLowerCase() == 'vegetarian'
                  ? AppColors.vegetarian.withOpacity(0.1)
                  : AppColors.nonVegetarian.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.restaurant,
                color: meal.dietPreference.toLowerCase() == 'vegetarian'
                    ? AppColors.vegetarian
                    : AppColors.nonVegetarian,
              ),
            ),
          ),
          AppSpacing.hMd,
          
          // Meal details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$mealType ($dietPreference)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppSpacing.vSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity: ${meal.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Here you could add price if available in your data model
                    Text(
                      '₹120.00',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard(Order order) {
    return AppCard(
      child: Column(
        children: [
          // Payment status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              _buildPaymentStatusBadge(order.paymentStatus),
            ],
          ),
          AppSpacing.vSm,
          
          // Payment method (this would come from your backend)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                StringConstants.creditCardEnding,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          AppSpacing.vSm,
          
          // Divider
          const Divider(),
          AppSpacing.vSm,
          
          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                StringConstants.totalAmount,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    // Only show cancel button if order is pending or confirmed
    final canCancel = order.status == OrderStatus.pending || 
                      order.status == OrderStatus.confirmed;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canCancel)
          AppButton(
            label: 'Cancel Order',
            onPressed: () => _cancelOrder(order),
            buttonType: AppButtonType.outline,
            buttonSize: AppButtonSize.medium,
            backgroundColor: AppColors.error.withOpacity(0.1),
            textColor: AppColors.error,
          ),
        
        // For demo purposes, let's add a button to update the status
        // In a real app, this would typically happen in the backend
        if (_isAdmin() && order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: AppButton(
              label: 'Update Status',
              onPressed: () => _showUpdateStatusDialog(order),
              buttonType: AppButtonType.outline,
              buttonSize: AppButtonSize.medium,
            ),
          ),
          
        // Re-order button
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: AppButton(
            label: 'Re-Order',
            onPressed: () {
              // Logic to create a new order with the same items
              // This would typically navigate to a confirmation screen
            },
            buttonType: AppButtonType.primary,
            buttonSize: AppButtonSize.medium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final Color color;
    final String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        text = 'Confirmed';
        break;
      case OrderStatus.preparing:
        color = AppColors.accent;
        text = 'Preparing';
        break;
      case OrderStatus.ready:
        color = AppColors.accent;
        text = 'Ready';
        break;
      case OrderStatus.outForDelivery:
        color = AppColors.primary;
        text = 'On the Way';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    final Color color;
    final String text;

    switch (status) {
      case PaymentStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case PaymentStatus.paid:
        color = AppColors.success;
        text = 'Paid';
        break;
      case PaymentStatus.failed:
        color = AppColors.error;
        text = 'Failed';
        break;
      case PaymentStatus.refunded:
        color = AppColors.info;
        text = 'Refunded';
        break;
      default:
        color = AppColors.textSecondary;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showUpdateStatusDialog(Order order) {
    final statusOptions = OrderStatus.values.where((s) => 
      s != order.status && 
      s != OrderStatus.cancelled
    ).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((status) {
            return ListTile(
              title: Text(_getStatusText(status)),
              onTap: () {
                Navigator.of(context).pop();
                _updateOrderStatus(order, status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.outForDelivery:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  // This method simulates admin check
  // In a real app, this would check user permissions
  bool _isAdmin() {
    return true; // For demo purposes
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(dateTime);
  }
}