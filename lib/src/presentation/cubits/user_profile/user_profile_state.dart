// lib/src/presentation/cubits/user_profile/user_profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();
  
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final User user;
  final List<Address>? addresses;
  
  const UserProfileLoaded({
    required this.user,
    this.addresses,
  });
  
  @override
  List<Object?> get props => [user, addresses];
}

class UserProfileUpdating extends UserProfileState {
  final User user;
  final String field;
  
  const UserProfileUpdating({
    required this.user,
    required this.field,
  });
  
  @override
  List<Object?> get props => [user, field];
}

class UserProfileUpdateSuccess extends UserProfileState {
  final User user;
  final String message;
  
  const UserProfileUpdateSuccess({
    required this.user,
    required this.message,
  });
  
  @override
  List<Object?> get props => [user, message];
}

class UserProfileError extends UserProfileState {
  final String message;
  
  const UserProfileError(this.message);
  
  @override
  List<Object?> get props => [message];
}