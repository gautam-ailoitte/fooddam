// lib/src/presentation/cubits/order_management/order_management_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/order_entity.dart' as order_entity;

enum OrderManagementStatus {
  initial,
  loading,
  loaded,
  updating,
  error
}

class OrderManagementState extends Equatable {
  final OrderManagementStatus status;
  final List<order_entity.Order> upcomingOrders;
  final List<order_entity.Order> orderHistory;
  final order_entity.Order? selectedOrder;
  final bool isLoading;
  final String? errorMessage;

  const OrderManagementState({
    this.status = OrderManagementStatus.initial,
    this.upcomingOrders = const [],
    this.orderHistory = const [],
    this.selectedOrder,
    this.isLoading = false,
    this.errorMessage,
  });

  OrderManagementState copyWith({
    OrderManagementStatus? status,
    List<order_entity.Order>? upcomingOrders,
    List<order_entity.Order>? orderHistory,
    order_entity.Order? selectedOrder,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrderManagementState(
      status: status ?? this.status,
      upcomingOrders: upcomingOrders ?? this.upcomingOrders,
      orderHistory: orderHistory ?? this.orderHistory,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasUpcomingOrders => upcomingOrders.isNotEmpty;
  bool get hasOrderHistory => orderHistory.isNotEmpty;

  @override
  List<Object?> get props => [
    status,
    upcomingOrders,
    orderHistory,
    selectedOrder,
    isLoading,
    errorMessage,
  ];
}