// lib/src/presentation/cubits/order/order_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';
import 'package:foodam/src/domain/usecase/order/create_order_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_by_id_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_user_orders_usecase.dart';
import 'package:foodam/src/domain/usecase/order/update_order_status_usecase.dart';
import 'package:foodam/src/domain/usecase/order/cancel_order_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_upcoming_orders_usecase.dart';
import 'package:foodam/src/domain/usecase/order/get_order_history_usecase.dart';
import 'package:foodam/src/presentation/cubits/order/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase _createOrderUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final GetUserOrdersUseCase _getUserOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final CancelOrderUseCase _cancelOrderUseCase;
  final GetUpcomingOrdersUseCase _getUpcomingOrdersUseCase;
  final GetOrderHistoryUseCase _getOrderHistoryUseCase;

  OrderCubit({
    required CreateOrderUseCase createOrderUseCase,
    required GetOrderByIdUseCase getOrderByIdUseCase,
    required GetUserOrdersUseCase getUserOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
    required GetUpcomingOrdersUseCase getUpcomingOrdersUseCase,
    required GetOrderHistoryUseCase getOrderHistoryUseCase,
  })  : _createOrderUseCase = createOrderUseCase,
        _getOrderByIdUseCase = getOrderByIdUseCase,
        _getUserOrdersUseCase = getUserOrdersUseCase,
        _updateOrderStatusUseCase = updateOrderStatusUseCase,
        _cancelOrderUseCase = cancelOrderUseCase,
        _getUpcomingOrdersUseCase = getUpcomingOrdersUseCase,
        _getOrderHistoryUseCase = getOrderHistoryUseCase,
        super(OrderInitial());

  Future<void> createOrder({
    required String subscriptionId,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    required List<Map<String, dynamic>> meals,
    String? cloudKitchenId,
    required double totalAmount,
    String? deliveryInstructions,
  }) async {
    emit(OrderLoading());
    
    final params = CreateOrderParams(
      subscriptionId: subscriptionId,
      deliveryDate: deliveryDate,
      deliveryAddress: deliveryAddress,
      meals: meals,
      cloudKitchenId: cloudKitchenId,
      totalAmount: totalAmount,
      deliveryInstructions: deliveryInstructions,
    );
    
    final result = await _createOrderUseCase(params);
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (order) => emit(OrderCreated(order: order)),
    );
  }

  Future<void> getOrderById(String orderId) async {
    emit(OrderLoading());
    
    final result = await _getOrderByIdUseCase(orderId);
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (order) => emit(OrderLoaded(order: order)),
    );
  }

  Future<void> getUserOrders({OrderStatus? status}) async {
    emit(OrderLoading());
    
    final params = GetUserOrdersParams(status: status);
    
    final result = await _getUserOrdersUseCase(params);
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (orders) => emit(OrdersLoaded(orders: orders)),
    );
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    emit(OrderLoading());
    
    final params = UpdateOrderStatusParams(
      orderId: orderId,
      status: status,
    );
    
    final result = await _updateOrderStatusUseCase(params);
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (order) => emit(OrderStatusUpdated(order: order)),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    emit(OrderLoading());
    
    final result = await _cancelOrderUseCase(orderId);
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (_) => emit(OrderCancelled(orderId: orderId)),
    );
  }

  Future<void> getUpcomingOrders() async {
    emit(OrderLoading());
    
    final result = await _getUpcomingOrdersUseCase();
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (orders) => emit(UpcomingOrdersLoaded(orders: orders)),
    );
  }

  Future<void> getOrderHistory() async {
    emit(OrderLoading());
    
    final result = await _getOrderHistoryUseCase();
    
    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (orders) => emit(OrderHistoryLoaded(orders: orders)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'Network error occurred. Please check your connection.';
      case CacheFailure:
        return 'Cache error occurred. Please restart the app.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}