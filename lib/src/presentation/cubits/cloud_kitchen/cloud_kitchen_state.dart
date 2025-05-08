// lib/src/presentation/cubits/cloud_kitchen/cloud_kitchen_state.dart
import 'package:equatable/equatable.dart';

abstract class CloudKitchenState extends Equatable {
  const CloudKitchenState();

  @override
  List<Object?> get props => [];
}

class CloudKitchenInitial extends CloudKitchenState {}

class CloudKitchenLoading extends CloudKitchenState {}

class CloudKitchenLoaded extends CloudKitchenState {
  final bool isServiceable;
  final String? cloudKitchenId;
  final String? distance;

  const CloudKitchenLoaded({
    required this.isServiceable,
    this.cloudKitchenId,
    this.distance,
  });

  @override
  List<Object?> get props => [isServiceable, cloudKitchenId, distance];
}

class CloudKitchenError extends CloudKitchenState {
  final String message;

  const CloudKitchenError(this.message);

  @override
  List<Object?> get props => [message];
}
