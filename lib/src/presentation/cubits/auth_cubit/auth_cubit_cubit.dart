// lib/src/presentation/cubits/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/auth_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';

/// Consolidated Auth Cubit
///
/// This class manages authentication state and operations:
/// - Login
/// - Demo login
/// - Logout
/// - Authentication status checks
class AuthCubit extends Cubit<AuthState> {
  final AuthUseCase _authUseCase;
  final LoggerService _logger = LoggerService();

  AuthCubit({
    required AuthUseCase authUseCase,
  }) : 
    _authUseCase = authUseCase,
    super(const AuthInitial());

  /// Check if user is already authenticated when app starts
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    
    final isLoggedInResult = await _authUseCase.isLoggedIn();
    
    await isLoggedInResult.fold(
      (failure) {
        _logger.e('Auth status check failed', error: failure);
        emit(const AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await _authUseCase.getCurrentUser();
          
          userResult.fold(
            (failure) {
              _logger.e('Failed to get current user', error: failure);
              emit(const AuthUnauthenticated());
            },
            (user) {
              emit(AuthAuthenticated(user: user));
            },
          );
        } else {
          emit(const AuthUnauthenticated());
        }
      }
    );
  }

  /// Log in with email and password
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    
    final result = await _authUseCase.login(email, password);
    
    result.fold(
      (failure) {
        _logger.e('Login failed', error: failure);
        emit(const AuthError(message: StringConstants.invalidCredentials));
      },
      (token) async {
        final userResult = await _authUseCase.getCurrentUser();
        
        userResult.fold(
          (failure) {
            _logger.e('Failed to get user after login', error: failure);
            emit(const AuthError(message: StringConstants.loginSuccessButUserFailed));
          },
          (user) {
            _logger.i('User logged in successfully: ${user.id}');
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  /// Demo login with predefined credentials
  Future<void> demoLogin() async {
    emit(const AuthLoading());
    
    // Using predefined demo credentials
    final result = await _authUseCase.login(
      'johndoe@example.com', 
      'password'
    );
    
    result.fold(
      (failure) {
        _logger.e('Demo login failed', error: failure);
        emit(const AuthError(message: 'Demo login failed. Please try again.'));
      },
      (token) async {
        final userResult = await _authUseCase.getCurrentUser();
        
        userResult.fold(
          (failure) {
            _logger.e('Failed to get user after demo login', error: failure);
            emit(const AuthError(message: 'Demo login successful but failed to get user details'));
          },
          (user) {
            _logger.i('User demo logged in successfully: ${user.id}');
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  /// Log out the current user
  Future<void> logout() async {
    emit(const AuthLoading());
    
    final result = await _authUseCase.logout();
    
    result.fold(
      (failure) {
        _logger.e('Logout failed', error: failure);
        // Even if logout fails server-side, clear local session
        emit(const AuthUnauthenticated());
      },
      (_) {
        _logger.i('User logged out successfully');
        emit(const AuthUnauthenticated());
      },
    );
  }
}