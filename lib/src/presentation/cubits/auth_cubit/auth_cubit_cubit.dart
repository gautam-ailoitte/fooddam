// lib/src/presentation/cubits/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/auth/login_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/auth/isLoggedIn_usecase.dart';
import 'package:foodam/src/domain/usecase/user/getcurrentuser_usecase.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LoggerService _logger = LoggerService();

  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : 
    _loginUseCase = loginUseCase,
    _logoutUseCase = logoutUseCase,
    _isLoggedInUseCase = isLoggedInUseCase,
    _getCurrentUserUseCase = getCurrentUserUseCase,
    super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final isLoggedInResult = await _isLoggedInUseCase();
    
    isLoggedInResult.fold(
      (failure) {
        _logger.e('Auth status check failed', error: failure);
        emit(AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await _getCurrentUserUseCase();
          
          userResult.fold(
            (failure) {
              _logger.e('Failed to get current user', error: failure);
              emit(AuthUnauthenticated());
            },
            (user) {
              emit(AuthAuthenticated(user: user));
            },
          );
        } else {
          emit(AuthUnauthenticated());
        }
      }
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    final params = LoginParams(email: email, password: password);
    final result = await _loginUseCase(params);
    
    result.fold(
      (failure) {
        _logger.e('Login failed', error: failure);
        emit(AuthError(StringConstants.invalidCredentials));
      },
      (token) async {
        final userResult = await _getCurrentUserUseCase();
        
        userResult.fold(
          (failure) {
            _logger.e('Failed to get user after login', error: failure);
            emit(AuthError(StringConstants.loginSuccessButUserFailed));
          },
          (user) {
            _logger.i('User logged in successfully: ${user.id}');
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  Future<void> demoLogin() async {
    emit(AuthLoading());
    
    // Using demo credentials (would be defined in StringConstants)
    final params = LoginParams(
      email: 'johndoe@example.com', 
      password: 'password'
    );
    
    final result = await _loginUseCase(params);
    
    result.fold(
      (failure) {
        _logger.e('Demo login failed', error: failure);
        emit(AuthError('Demo login failed. Please try again.'));
      },
      (token) async {
        final userResult = await _getCurrentUserUseCase();
        
        userResult.fold(
          (failure) {
            _logger.e('Failed to get user after demo login', error: failure);
            emit(AuthError('Demo login successful but failed to get user details'));
          },
          (user) {
            _logger.i('User demo logged in successfully: ${user.id}');
            emit(AuthAuthenticated(user: user));
          },
        );
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    final result = await _logoutUseCase();
    
    result.fold(
      (failure) {
        _logger.e('Logout failed', error: failure);
        // Even if logout fails server-side, clear local session
        emit(AuthUnauthenticated());
      },
      (_) {
        _logger.i('User logged out successfully');
        emit(AuthUnauthenticated());
      },
    );
  }
}