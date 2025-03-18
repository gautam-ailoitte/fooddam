// lib/src/presentation/cubits/order/order_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderLoaded extends OrderState {
  final Order order;

  const OrderLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrdersLoaded extends OrderState {
  final List<Order> orders;

  const OrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderStatusUpdated extends OrderState {
  final Order order;

  const OrderStatusUpdated({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderCancelled extends OrderState {
  final String orderId;

  const OrderCancelled({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class UpcomingOrdersLoaded extends OrderState {
  final List<Order> orders;

  const UpcomingOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryLoaded extends OrderState {
  final List<Order> orders;

  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}