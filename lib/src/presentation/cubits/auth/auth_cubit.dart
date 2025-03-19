// lib/src/presentation/cubits/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/errors/failure.dart';
import 'package:foodam/src/domain/entities/address_entity.dart';
import 'package:foodam/src/domain/entities/dish_entity.dart';
import 'package:foodam/src/domain/usecase/user/check_logged_in_usecase.dart';
import 'package:foodam/src/domain/usecase/user/get_current_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/login_user_usecase.dart';
import 'package:foodam/src/domain/usecase/user/logout_usecase.dart';
import 'package:foodam/src/domain/usecase/user/register_user_usecase.dart';
import 'package:foodam/src/presentation/cubits/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUserUseCase _loginUserUseCase;
  final RegisterUserUseCase _registerUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CheckLoggedInUseCase _checkLoggedInUseCase;

  AuthCubit({
    required LoginUserUseCase loginUserUseCase,
    required RegisterUserUseCase registerUserUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CheckLoggedInUseCase checkLoggedInUseCase,
  })  : _loginUserUseCase = loginUserUseCase,
        _registerUserUseCase = registerUserUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _checkLoggedInUseCase = checkLoggedInUseCase,
        super(const AuthState());

  // Check if user is already logged in when app starts
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final isLoggedInResult = await _checkLoggedInUseCase();

    isLoggedInResult.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
      )),
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await _getCurrentUserUseCase();
          userResult.fold(
            (failure) => emit(state.copyWith(
              status: AuthStatus.unauthenticated,
            )),
            (user) => emit(state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
            )),
          );
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      },
    );
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final params = LoginUserParams(email: email, password: password);
    final result = await _loginUserUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  // Register a new user
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required Address address,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? allergies,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final params = RegisterUserParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
      address: address,
      dietaryPreferences: dietaryPreferences,
      allergies: allergies,
    );

    final result = await _registerUserUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  // Logout user
  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _mapFailureToMessage(failure),
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      )),
    );
  }

  // Helper method to map failures to user-friendly messages
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case UnauthorizedFailure:
        return 'Invalid credentials. Please try again.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}