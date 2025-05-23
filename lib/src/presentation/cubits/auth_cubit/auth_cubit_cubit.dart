// lib/src/presentation/cubits/auth_cubit/auth_cubit_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/constants/string_constants.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/core/service/logger_service.dart';
import 'package:foodam/src/domain/usecase/auth_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth_cubit/auth_cubit_state.dart';

/// Consolidated Auth Cubit with proper profile completion handling
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
          await _fetchCurrentUser();
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  /// Fetch current user and handle profile completion check
  Future<void> _fetchCurrentUser() async {
    final userResult = await _authUseCase.getCurrentUser();

    userResult.fold(
      (failure) {
        _logger.e('Failed to get current user', error: failure);
        emit(const AuthUnauthenticated());
      },
      (user) {
        // Check if profile is complete (has name)
        final needsCompletion =
            user.firstName == null ||
            user.lastName == null ||
            user.firstName!.isEmpty ||
            user.lastName!.isEmpty;

        _logger.i(
          'User auth status: ${user.id}, needs completion: $needsCompletion',
        );

        emit(
          AuthAuthenticated(
            user: user,
            needsProfileCompletion: needsCompletion,
          ),
        );
      },
    );
  }

  /// Helper method to handle successful authentication
  Future<void> _handleSuccessfulAuth(String token) async {
    // After login/registration, get user details
    await _fetchCurrentUser();
  }

  /// Request password reset
  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());

    final result = await _authUseCase.forgotPassword(email);

    result.fold(
      (failure) {
        _logger.e('Forgot password request failed', error: failure);
        emit(
          const AuthError(
            message: 'Failed to process your request. Please try again.',
          ),
        );
      },
      (message) {
        _logger.i('Password reset OTP sent successfully');
        emit(const AuthPasswordResetSent());
      },
    );
  }

  /// Reset password with token
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    emit(const AuthLoading());

    final result = await _authUseCase.resetPassword(email, otp, newPassword);

    result.fold(
      (failure) {
        _logger.e('Reset password failed', error: failure);
        emit(
          AuthError(
            message:
                failure.message ??
                'Failed to reset password. Please try again.',
          ),
        );
      },
      (_) {
        _logger.i('Password reset successfully');
        emit(const AuthUnauthenticated());
      },
    );
  }

  /// Register with email and password
  Future<void> register(
    String email,
    String password,
    String phone,
    bool acceptTerms,
  ) async {
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
          emit(AuthError(message: failure.message ?? 'Validation failed'));
        } else {
          emit(
            const AuthError(message: 'Registration failed. Please try again.'),
          );
        }
      },
      (message) {
        _logger.i('User registered successfully: $email');
        // For email registration, we return to login for verification
        emit(AuthRegistrationSuccess(email: email, message: message));
      },
    );
  }

  /// Register with mobile
  Future<void> registerWithMobile(String mobile, bool acceptTerms) async {
    emit(const AuthLoading());

    // Create a RegisterMobileParams object
    final registerParams = RegisterMobileParams(
      mobile: mobile,
      acceptTerms: acceptTerms,
    );

    final result = await _authUseCase.registerWithMobile(registerParams);

    result.fold(
      (failure) {
        _logger.e('Mobile registration failed', error: failure);
        emit(
          AuthError(
            message:
                failure.message ?? 'Registration failed. Please try again.',
          ),
        );
      },
      (message) {
        _logger.i('OTP sent to mobile for verification: $mobile');
        emit(AuthOTPSent(identifier: mobile, message: message));
      },
    );
  }

  /// Verify mobile OTP
  Future<void> verifyMobileOTP(String mobile, String otp) async {
    emit(const AuthLoading());

    final result = await _authUseCase.verifyMobileOTP(mobile, otp);

    result.fold(
      (failure) {
        _logger.e('OTP verification failed', error: failure);
        emit(
          AuthError(
            message:
                failure.message ?? 'OTP verification failed. Please try again.',
          ),
        );
      },
      (token) async {
        await _handleSuccessfulAuth(token);
      },
    );
  }

  Future<void> resendOTP(String mobile, bool isRegistration) async {
    emit(const AuthLoading());

    final result = await _authUseCase.resendOTP(mobile, isRegistration);

    result.fold(
      (failure) {
        _logger.e('OTP resend failed', error: failure);
        emit(
          AuthError(
            message:
                failure.message ?? 'Failed to resend OTP. Please try again.',
          ),
        );
      },
      (message) {
        _logger.i('OTP resent successfully to: $mobile');
        emit(AuthOTPSent(identifier: mobile, message: message));
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
        if (failure is EmailNotVerifiedFailure) {
          emit(
            const AuthError(
              message:
                  'Email not verified. Please check your inbox for verification email.',
            ),
          );
        } else {
          emit(const AuthError(message: StringConstants.invalidCredentials));
        }
      },
      (token) async {
        await _handleSuccessfulAuth(token);
      },
    );
  }

  /// Login with mobile OTP
  Future<void> requestLoginOTP(String mobile) async {
    emit(const AuthLoading());

    final result = await _authUseCase.requestLoginOTP(mobile);

    result.fold(
      (failure) {
        _logger.e('OTP request failed', error: failure);
        emit(
          AuthError(
            message: failure.message ?? 'Failed to send OTP. Please try again.',
          ),
        );
      },
      (message) {
        _logger.i('OTP sent for login: $mobile');
        emit(AuthOTPSent(identifier: mobile, message: message));
      },
    );
  }

  /// Verify login OTP
  Future<void> verifyLoginOTP(String mobile, String otp) async {
    emit(const AuthLoading());

    final result = await _authUseCase.verifyLoginOTP(mobile, otp);

    result.fold(
      (failure) {
        _logger.e('Login OTP verification failed', error: failure);
        emit(
          AuthError(
            message:
                failure.message ?? 'OTP verification failed. Please try again.',
          ),
        );
      },
      (token) async {
        await _handleSuccessfulAuth(token);
      },
    );
  }

  /// Demo login with predefined credentials
  Future<void> demoLogin() async {
    emit(const AuthLoading());
    // Create a LoginParams object with the provided email and password
    final loginParams = LoginParams(
      email: "abhias.dev@gmail.com",
      password: "Abhi",
    );

    final result = await _authUseCase.login(loginParams);

    result.fold(
      (failure) {
        _logger.e('Demo login failed', error: failure);
        emit(const AuthError(message: 'Demo login failed. Please try again.'));
      },
      (token) async {
        await _handleSuccessfulAuth(token);
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
