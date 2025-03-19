// lib/src/presentation/cubits/order_management/order_management_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;
import 'package:foodam/src/domain/usecase/order/cancel_order_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_history_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_upcoming_orders_usecase.dart';
import 'package:foodam/src/domain/usecase/order/update_order_status_usecase.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';

class OrderManagementCubit extends Cubit<OrderManagementState> {
  final GetUpcomingOrdersUseCase _getUpcomingOrdersUseCase;
  final GetOrderHistoryUseCase _getOrderHistoryUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;

  OrderManagementCubit({
    required GetUpcomingOrdersUseCase getUpcomingOrdersUseCase,
    required GetOrderHistoryUseCase getOrderHistoryUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
  })  : _getUpcomingOrdersUseCase = getUpcomingOrdersUseCase,
        _getOrderHistoryUseCase = getOrderHistoryUseCase,
        _getOrderByIdUseCase = getOrderByIdUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase,
        _cancelOrderUseCase = cancelOrderUseCase,
        super(const OrderManagementState());

  // Load upcoming orders
  Future<void> loadUpcomingOrders() async {
    emit(state.copyWith(
      status: OrderManagementStatus.loading,
      isLoading: true,
    ));

    final result = await _getUpcomingOrdersUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: OrderManagementStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (orders) => emit(state.copyWith(
        status: OrderManagementStatus.loaded,
        upcomingOrders: orders,
        isLoading: false,
      )),
    );
  }

  // Load order history
  Future<void> loadOrderHistory() async {
    emit(state.copyWith(
      status: OrderManagementStatus.loading,
      isLoading: true,
    ));

    final result = await _getOrderHistoryUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: OrderManagementStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (orders) => emit(state.copyWith(
        status: OrderManagementStatus.loaded,
        orderHistory: orders,
        isLoading: false,
      )),
    );
  }

  // Get order details by ID
  Future<void> getOrderDetails(String orderId) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getOrderByIdUseCase(orderId);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (order) => emit(state.copyWith(
        selectedOrder: order,
        isLoading: false,
      )),
    );
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, order_entity.OrderStatus newStatus) async {
    emit(state.copyWith(
      status: OrderManagementStatus.updating,
      isLoading: true,
    ));

    final params = UpdateOrderStatusParams(
      orderId: orderId,
      status: newStatus,
    );

    final result = await _updateOrderStatusUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OrderManagementStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (updatedOrder) {
        // Update state with new order status
        if (state.selectedOrder?.id == updatedOrder.id) {
          emit(state.copyWith(selectedOrder: updatedOrder));
        }
        
        // Update lists based on order status
        if (newStatus == order_entity.OrderStatus.delivered || 
            newStatus == order_entity.OrderStatus.cancelled) {
          // Move to history if delivered or cancelled
          final newUpcoming = List<order_entity.Order>.from(state.upcomingOrders)
            ..removeWhere((order) => order.id == updatedOrder.id);
            
          final newHistory = List<order_entity.Order>.from(state.orderHistory)
            ..add(updatedOrder);
            
          emit(state.copyWith(
            status: OrderManagementStatus.loaded,
            upcomingOrders: newUpcoming,
            orderHistory: newHistory,
            isLoading: false,
          ));
        } else {
          // Update in upcoming orders
          final newUpcoming = List<order_entity.Order>.from(state.upcomingOrders);
          final index = newUpcoming.indexWhere((order) => order.id == updatedOrder.id);
          
          if (index != -1) {
            newUpcoming[index] = updatedOrder;
          }
          
          emit(state.copyWith(
            status: OrderManagementStatus.loaded,
            upcomingOrders: newUpcoming,
            isLoading: false,
          ));
        }
      },
    );
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    emit(state.copyWith(
      status: OrderManagementStatus.updating,
      isLoading: true,
    ));

    final result = await _cancelOrderUseCase(orderId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: OrderManagementStatus.error,
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) {
        // Remove from upcoming orders and add to history with cancelled status
        final order = state.upcomingOrders.firstWhere(
          (order) => order.id == orderId,
          orElse: () => throw Exception('Order not found'),
        );
        
        // Create cancelled version
        final cancelledOrder = order_entity.Order(
          id: order.id,
          orderNumber: order.orderNumber,
          userId: order.userId,
          subscriptionId: order.subscriptionId,
          deliveryDate: order.deliveryDate,
          deliveryAddress: order.deliveryAddress,
          cloudKitchenId: order.cloudKitchenId,
          status: order_entity.OrderStatus.cancelled,
          paymentStatus: order.paymentStatus,
          totalAmount: order.totalAmount,
          meals: order.meals,
          deliveryInstructions: order.deliveryInstructions,
          createdAt: order.createdAt,
          updatedAt: DateTime.now(),
        );
        
        // Update state
        final newUpcoming = List<order_entity.Order>.from(state.upcomingOrders)
          ..removeWhere((o) => o.id == orderId);
          
        final newHistory = List<order_entity.Order>.from(state.orderHistory)
          ..add(cancelledOrder);
          
        emit(state.copyWith(
          status: OrderManagementStatus.loaded,
          upcomingOrders: newUpcoming,
          orderHistory: newHistory,
          selectedOrder: state.selectedOrder?.id == orderId ? cancelledOrder : state.selectedOrder,
          isLoading: false,
        ));
      },
    );
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}