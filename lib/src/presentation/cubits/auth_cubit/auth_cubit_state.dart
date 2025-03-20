// lib/src/presentation/cubits/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
  
  const AuthAuthenticated({required this.user, required this.token});
  
  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}