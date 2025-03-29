// lib/src/presentation/cubits/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/errors/failure.dart';
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

  AuthCubit({required AuthUseCase authUseCase})
    : _authUseCase = authUseCase,
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
      },
    );
  }
/// Register a new user
Future<void> register(String email, String password, String phone, bool acceptTerms) async {
  emit(const AuthLoading());
  
  // Create a RegisterParams object with the provided data
  final registerParams = RegisterParams(
    email: email,
    password: password,
    phone: phone,
    acceptTerms: acceptTerms,
  );

  final result = await _authUseCase.register(registerParams);

  result.fold(
    (failure) {
      _logger.e('Registration failed', error: failure);
      if (failure is UserAlreadyExistsFailure) {
        emit(const AuthError(message: 'This email is already registered'));
      } else if (failure is ValidationFailure) {
        emit(AuthError(message: failure.message));
      } else {
        emit(const AuthError(message: 'Registration failed. Please try again.'));
      }
    },
    (token) async {
      final userResult = await _authUseCase.getCurrentUser();

      userResult.fold(
        (failure) {
          _logger.e('Failed to get user after registration', error: failure);
          emit(
            const AuthError(
              message: 'Registration successful but failed to get user details',
            ),
          );
        },
        (user) {
          _logger.i('User registered successfully: ${user.id}');
          emit(AuthAuthenticated(user: user));
        },
      );
    },
  );
}

  /// Log in with email and password
  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    // Create a LoginParams object with the provided email and password
    final loginParams = LoginParams(email: email, password: password);

    final result = await _authUseCase.login(loginParams);

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
            emit(
              const AuthError(
                message: StringConstants.loginSuccessButUserFailed,
              ),
            );
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
    // Create a LoginParams object with the provided email and password
    final loginParams = LoginParams(
      email: "prince@gmail.com",
      password: "Prince@2002",
    );
    // Using predefined demo credentials
    final result = await _authUseCase.login(loginParams);

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
            emit(
              const AuthError(
                message: 'Demo login successful but failed to get user details',
              ),
            );
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
