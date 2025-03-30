// lib/src/presentation/cubits/auth_cubit/auth_cubit_state.dart
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
  final bool needsProfileCompletion;
  
  const AuthAuthenticated({
    required this.user, 
    this.needsProfileCompletion = false
  });
  
  @override
  List<Object?> get props => [user, needsProfileCompletion];
  
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

/// State when password reset email has been sent
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Error state for authentication operations
class AuthError extends AuthState {
  final String message;
  
  const AuthError({required this.message});
  
  @override
  List<Object?> get props => [message];
}