// lib/src/presentation/cubits/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:foodam/src/domain/entities/user_entity.dart';

/// Base state for all authentication-related states
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when authentication status hasn't been determined
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state for authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when the user is authenticated
class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
  
  String? get displayName => user.fullName ?? user.email;
  
  bool get hasFullProfile => 
      user.firstName != null && 
      user.lastName != null &&
      user.phone != null;
}

/// State when the user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Error state for authentication operations
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}